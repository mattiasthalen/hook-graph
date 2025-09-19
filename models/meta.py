import polars as pl
import typing as t
import yaml

from datetime import datetime
from sqlmesh import ExecutionContext, model

with open("./manifest.yml", "r") as file:
    manifest = yaml.safe_load(file)

enabled_models = True

concepts = manifest.get("concepts")
keysets = manifest.get("keysets")
frames =  manifest.get("frames")
hooks = []

for frame in frames:
    for hook in frame.get("hooks"):
        hook_row = {"frame": frame["name"], **hook}
        hooks.append(hook_row)


@model(
    "meta.concepts",
    enabled=enabled_models,
    kind="full",
    columns={
        "name": "text",
        "description": "text",
    }
)
def execute( # type: ignore
    context: ExecutionContext,
    start: datetime,
    end: datetime,
    execution_time: datetime,
    **kwargs: t.Any,
) -> pl.DataFrame:
    return pl.from_dicts(concepts)


@model(
    "meta.keysets",
    enabled=enabled_models,
    kind="full",
    columns={
        "name": "text",
        "concept": "text",
        "source_system": "text",
        "description": "text",
    }
)
def execute( # type: ignore
    context: ExecutionContext,
    start: datetime,
    end: datetime,
    execution_time: datetime,
    **kwargs: t.Any,
) -> pl.DataFrame:
    return pl.from_dicts(keysets)


@model(
    "meta.frames",
    enabled=enabled_models,
    kind="full",
    columns={
        "name": "text",
        "source_table": "text",
        "description": "text",
    }
)
def execute( # type: ignore
    context: ExecutionContext,
    start: datetime,
    end: datetime,
    execution_time: datetime,
    **kwargs: t.Any,
) -> pl.DataFrame:
    return pl.from_dicts(frames).drop("hooks")


@model(
    "meta.hooks",
    enabled=enabled_models,
    kind="full",
    columns={
        "frame": "text",
        "name": "text",
        "concept": "text",
        "keyset": "text",
        "business_key_field": "text",
    }
)
def execute( # type: ignore
    context: ExecutionContext,
    start: datetime,
    end: datetime,
    execution_time: datetime,
    **kwargs: t.Any,
) -> pl.DataFrame:
    return pl.from_dicts(hooks)
