import asyncio
import json
import logging
import click
from kubernetes_asyncio import client, config
from kubernetes_asyncio.client.api_client import ApiClient
from kubernetes_asyncio.client.exceptions import ApiException

logger = logging.getLogger("evict")


@click.command(help="Evict pods from a Kubernetes cluster")
@click.option("--all", "-a", "_all", is_flag=True, help="Evict all pods in the namespace")
@click.option("--all-namespaces", "-A", is_flag=True, help="Evict all pods in all namespaces")
@click.option("--namespace", "-n", default="default", help="Namespace of the pod")
@click.option("--selector", "-l", default="", help="Label selector to filter pods")
@click.option("-v", "--v", "verbosity", default=3, help="Set log level")
@click.argument("pod_name", default="", nargs=1)
def main(
    _all: bool, all_namespaces: bool, namespace: str, selector: str, pod_name: str, verbosity: int
):
    if not _all and not selector and not pod_name:
        raise click.UsageError("Must specify exactly one of --all, --selector, or a pod name.")
    if selector and pod_name:
        raise click.UsageError("Cannot specify both --selector and a pod name.")
    if _all and selector:
        raise click.UsageError("Cannot specify both --all and --selector.")
    if _all and pod_name:
        raise click.UsageError("Cannot specify both --all and a pod name.")
    if all_namespaces and namespace != "default":
        raise click.UsageError("Cannot specify both --all-namespaces and --namespace.")
    set_log_level(verbosity)
    asyncio.run(_main(_all, all_namespaces, namespace, selector, pod_name))


def set_log_level(verbosity: int):
    level = (
        logging.FATAL,
        logging.ERROR,
        logging.WARNING,
        logging.INFO,
        logging.DEBUG,
    )
    logger.setLevel(level[min(max(verbosity, 0), len(level) - 1)])


async def _main(
    _all: bool,
    all_namespaces: bool,
    namespace: str,
    selector: str,
    pod_name: str,
):
    await config.load_kube_config()
    async with ApiClient() as api:
        v1 = client.CoreV1Api(api)
        if all_namespaces:
            namespaces = (await v1.list_namespace()).items
        else:
            namespaces = [await v1.read_namespace(namespace)]

        pods: list[client.V1Pod] = await list_pods(v1, _all, namespaces, selector, pod_name)

        _ = await asyncio.gather(*(evict_pod(v1, pod) for pod in pods))


async def list_pods(
    v1: client.CoreV1Api,
    _all: bool,
    namespaces: list[client.V1Namespace],
    selector: str,
    pod_name: str,
) -> list[client.V1Pod]:
    pods: list[client.V1Pod] = []
    for ns in namespaces:
        if pod_name:
            try:
                pods.append(await v1.read_namespaced_pod(pod_name, ns.metadata.name))
            except ApiException as e:
                if e.status != 404:
                    raise e
        elif selector:
            selected_pods = await v1.list_namespaced_pod(ns.metadata.name, label_selector=selector)
            pods.extend(selected_pods.items)
        elif _all:
            namespace_pods = await v1.list_namespaced_pod(ns.metadata.name)
            pods.extend(namespace_pods.items)
    return pods


async def evict_pod(v1: client.CoreV1Api, pod: client.V1Pod):
    eviction = client.V1Eviction(
        metadata=client.V1ObjectMeta(name=pod.metadata.name, namespace=pod.metadata.namespace)
    )
    logger.debug(f'evicting pod "{pod.metadata.name}" from namespace {pod.metadata.namespace}')
    try:
        await v1.create_namespaced_pod_eviction(
            name=pod.metadata.name, namespace=pod.metadata.namespace, body=eviction
        )
        logger.info(f'pod "{pod.metadata.name}" evicted from namespace {pod.metadata.namespace}')
    except ApiException as e:
        if e.status in (404, 429):
            body = json.loads(e.body) if e.body else {}
            logger.warning(f"Error from server ({e.reason}): {body.get('message', '')}")
        else:
            raise e


if __name__ == "__main__":
    main()
