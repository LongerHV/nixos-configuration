import base64
import contextlib
import os
from datetime import datetime, timedelta
from pathlib import Path

import click
import yaml
from cryptography import x509
from cryptography.x509.base import Certificate
from dacite import from_dict
from rich.console import Console
from rich.table import Table
from rich.text import Text

from .kubeconfig import KubeConfig, User, transform_to_snake_case


def load_config() -> KubeConfig:
    config_path = Path(os.environ.get("KUBECONFIG", "~/.kube/config")).expanduser()
    with config_path.open("r") as f:
        data = yaml.safe_load(f)
    transformed_data = transform_to_snake_case(data)
    return from_dict(data_class=KubeConfig, data=transformed_data)  # type: ignore


def style(delta: timedelta) -> str:
    if delta < timedelta():
        return "red"
    if delta < timedelta(days=7):
        return "yellow"
    return "green"


def extract_user_certificate(user: User) -> Certificate | None:
    certificate_data: str | None = user.user.get("client_certificate_data")
    if not certificate_data:
        return None
    decoded_certificate_data = base64.b64decode(certificate_data)
    return x509.load_pem_x509_certificate(decoded_certificate_data)


@contextlib.contextmanager
def table():
    console = Console()
    table = Table(title="Client certificates")
    table.add_column("User config")
    table.add_column("Valid for")
    yield table
    console.print(table)


@click.command()
def main():
    config = load_config()
    now = datetime.now()

    with table() as t:
        for user in config.users:
            certificate = extract_user_certificate(user)
            if certificate is None:
                continue
            remaining = certificate.not_valid_after - now
            t.add_row(
                Text(user.name),
                Text(f"{remaining.days} days"),
                style=style(remaining),
            )


if __name__ == "__main__":
    main()
