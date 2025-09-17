import yaml

from sqlglot import exp
from sqlmesh.core.model import model
from sqlmesh.core.macros import MacroEvaluator

with open("./models/manifest.yml", "r") as file:
    manifest = yaml.safe_load(file)

blueprints =  manifest.get("frames")

@model(
    "hook.@{name}",
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

    hook_expressions = []
    for hook in hooks:
        hook_name = hook.get("name")
        hook_keyset = hook.get("keyset")
        hook_business_key_field = hook.get("business_key_field")

        hook_expression = f"""
        CASE
            WHEN {hook_business_key_field} IS NOT NULL
            THEN '{hook_keyset}|' || TRIM({hook_business_key_field}::TEXT)
        END AS {hook_name}
        """
        hook_expressions.append(hook_expression)

    sql = f"""
    SELECT
        HASH(*COLUMNS(* EXCLUDE(record__valid_to))) AS uid__{name},
        {', '.join(hook_expressions)},
        *
    FROM scd.{name}
    """

    return sql