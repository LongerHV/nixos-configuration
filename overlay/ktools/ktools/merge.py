import itertools
import json
import logging
import os
import subprocess
from dataclasses import asdict
from pathlib import Path
from typing import NamedTuple, TypeVar
from collections.abc import Iterable

import click
import yaml
from dacite import from_dict

from .kubeconfig import (Cluster, Context, ContextConfig, KubeConfig, User,
                         transform_to_kebab_case, transform_to_snake_case)

T = TypeVar("T")


class NameAndConfig(NamedTuple):
    name: str
    config: KubeConfig


def load_config(path: Path) -> NameAndConfig | None:
    suffix = path.suffix
    name = path.name.removesuffix(suffix)
    with path.open("r") as f:
        match suffix:
            case ".json":
                data = json.load(f)
            case ".yml" | ".yaml" | ".kubeconfig":
                data = yaml.safe_load(f)
            case _:
                return None
    transformed_data = transform_to_snake_case(data)
    data = from_dict(data_class=KubeConfig, data=transformed_data)  # type: ignore
    return NameAndConfig(name, data)


def load_all_configs(path: Path) -> Iterable[NameAndConfig]:
    loaded_configs = map(load_config, path.iterdir())
    return filter(None, loaded_configs)


def get_first_by_name(name: str | None, iterable: Iterable[T]) -> T:
    return next(filter(lambda i: i.name == name, iterable))  # type: ignore


def process_config(name_and_config: NameAndConfig) -> KubeConfig | None:
    name, config = name_and_config
    try:
        current_context = get_first_by_name(config.current_context, config.contexts)
        current_user = get_first_by_name(current_context.context.user, config.users)
        current_cluster = get_first_by_name(
            current_context.context.cluster, config.clusters
        )
    except StopIteration:
        logging.warn(f"Invalid kubeconfig: {name}")
        return None

    return KubeConfig(
        kind="Config",
        apiVersion="v1",
        contexts=[
            Context(
                name=name,
                context=ContextConfig(
                    cluster=f"{name}-cluster",
                    user=f"{name}-user",
                ),
            ),
        ],
        clusters=[
            Cluster(
                name=f"{name}-cluster",
                cluster=current_cluster.cluster,
            ),
        ],
        users=[
            User(
                name=f"{name}-user",
                user=current_user.user,
            ),
        ],
    )


def merge_configs(configs: list[KubeConfig]) -> KubeConfig:
    def merge_map(func):
        return list(itertools.chain.from_iterable(map(func, configs)))

    return KubeConfig(
        kind="Config",
        apiVersion="v1",
        current_context=configs[0].contexts[0].name,
        contexts=merge_map(lambda config: config.contexts),
        clusters=merge_map(lambda config: config.clusters),
        users=merge_map(lambda config: config.users),
    )


def dump_config(path: Path, config: KubeConfig):
    with path.open("w") as f:
        data = transform_to_kebab_case(asdict(config))
        yaml.dump(data, f)
    path.chmod(0o600)


def login_tsh():
    subprocess.run(
        ["tsh", "kube", "login", "--all", "--set-context-name", "tsh-{{.KubeName}}"],
        check=True,
    )


@click.command()
def main():
    home = Path.home()
    target_config = Path(os.getenv("KUBECONFIG", "~/.kube/config")).expanduser()
    if target_config == Path("~/.kube/config-prod").expanduser():
        print("Using production kubeconfig")
        config_dir = home / ".kubeconfig-prod"
    else:
        config_dir = home / ".kubeconfig"
    config_dir.mkdir(exist_ok=True)
    target_config.parent.mkdir(exist_ok=True)

    raw_configs = load_all_configs(config_dir)
    processed_configs = list(filter(None, map(process_config, raw_configs)))
    assert len(processed_configs) > 0
    merged_configs = merge_configs(processed_configs)
    dump_config(target_config, merged_configs)
    # login_tsh()


if __name__ == "__main__":
    main()
