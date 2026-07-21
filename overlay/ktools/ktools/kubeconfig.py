import functools
from dataclasses import dataclass, field
from typing import Any, Literal, TypeAlias

JSON: TypeAlias = str | float | int | list["JSON"] | dict[str, "JSON"]


@dataclass
class ContextConfig:
    cluster: str
    user: str


@dataclass
class Context:
    name: str
    context: ContextConfig


@dataclass
class Cluster:
    name: str
    cluster: dict[str, Any]


@dataclass
class User:
    name: str
    user: dict[str, Any]


@dataclass
class KubeConfig:
    kind: Literal["Config"]
    apiVersion: Literal["v1"]
    current_context: str | None = None
    clusters: list[Cluster] = field(default_factory=list)
    contexts: list[Context] = field(default_factory=list)
    users: list[User] = field(default_factory=list)


def transform_data_keys(old: str, new: str, data: JSON) -> JSON:
    transform = functools.partial(transform_data_keys, old, new)
    match data:
        case list():
            return list(map(transform, data))
        case dict():
            return {k.replace(old, new): transform(v) for k, v in data.items()}
        case _:
            return data


transform_to_snake_case = functools.partial(transform_data_keys, "-", "_")
transform_to_kebab_case = functools.partial(transform_data_keys, "_", "-")
