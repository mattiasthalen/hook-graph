import yaml

from sqlglot import exp
from sqlmesh.core.model import model
from sqlmesh.core.macros import MacroEvaluator

@model(
    "graph.edges",
    enabled=True,
    is_sql=True,
    kind="VIEW",
)
def entrypoint(evaluator: MacroEvaluator) -> str | exp.Expression:
    with open("./models/manifest.yml", "r") as file:
        manifest = yaml.safe_load(file)

    frames =  manifest.get("frames")

    expressions = []

    for frame in frames:
        frame_name = frame.get("name")

        for from_hook in frame.get("hooks"):
            from_hook_name = from_hook.get("name")
            from_concept = from_hook.get("concept")
            from_keyset = from_hook.get("keyset")

            for to_hook in frame.get("hooks"):
                to_hook_name = to_hook.get("name")
                to_concept = to_hook.get("concept")
                to_keyset = to_hook.get("keyset")

                if from_hook_name == to_hook_name:
                    continue

                expression = f"""
                SELECT
                    '{frame_name}' AS frame,
                    '{from_concept}' AS from_concept,
                    '{from_keyset}' AS from_keyset,
                    '{from_hook_name}' AS from_hook_name,
                    {from_hook_name} AS from_hook,
                    '{to_concept}' AS to_concept,
                    '{to_keyset}' AS to_keyset,
                    {to_hook_name} AS to_hook,
                    '{to_hook_name}' AS to_hook_name
                FROM hook.{frame_name}
                WHERE {from_hook_name} IS NOT NULL AND {to_hook_name} IS NOT NULL
                """

                expressions.append(expression)

    sql = "UNION ALL".join(expressions)

    return sql