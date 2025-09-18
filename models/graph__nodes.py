import yaml

from sqlglot import exp
from sqlmesh.core.model import model
from sqlmesh.core.macros import MacroEvaluator

@model(
    "graph.nodes",
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
            hook_name = from_hook.get("name")
            concept = from_hook.get("concept")
            keyset = from_hook.get("keyset")

            expression = f"""
            SELECT
                '{frame_name}' AS frame,
                '{concept}' AS concept,
                '{keyset}' AS keyset,
                '{hook_name}' AS hook_name,
                {hook_name} AS hook
            FROM hook.{frame_name}
            WHERE {hook_name} IS NOT NULL
            """

            expressions.append(expression)

    sql = "UNION ALL".join(expressions)

    return sql