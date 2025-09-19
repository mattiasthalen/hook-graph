import yaml

from sqlglot import exp
from sqlmesh.core.model import model
from sqlmesh.core.macros import MacroEvaluator

with open("./manifest.yml", "r") as file:
    manifest = yaml.safe_load(file)

blueprints =  manifest.get("frames")

@model(
    "uss.@{name}",
    enabled=True,
    is_sql=True,
    kind="VIEW",
    description="@{description}",
    grains="uid__@{name}",
    blueprints=blueprints,
)
def entrypoint(evaluator: MacroEvaluator) -> str | exp.Expression:

    name = evaluator.blueprint_var("name")
    hooks = evaluator.blueprint_var("hooks")

    assert hooks, f"No hooks defined for frame {name}"

    ignore_hooks = [h["name"] for h in hooks]

    sql = f"""
    SELECT
        record__uid AS uid__{name},
        * EXCLUDE (record__uid, {', '.join(ignore_hooks)})
    FROM hook.{name}
    """

    return sql