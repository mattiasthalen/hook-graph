MODEL (
  name graph.safe_edges,
  enabled TRUE,
  kind VIEW
);

WITH cte__nodes AS (
  SELECT
    *
  FROM graph.nodes
), cte__edges AS (
  SELECT
    *
  FROM graph.edges
), cte__from_stats AS (
  SELECT
    frame AS from_frame,
    from_concept,
    from_keyset,
    from_hook_name,
    to_concept,
    to_keyset,
    COUNT(*) AS from_count
  FROM cte__edges
  GROUP BY ALL
), cte__to_stats AS (
  SELECT
    cte__edges.frame AS from_frame,
    cte__edges.from_concept,
    cte__edges.from_keyset,
    cte__edges.from_hook_name,
    cte__nodes.frame AS to_frame,
    cte__edges.to_concept,
    cte__edges.to_keyset,
    cte__nodes.hook_name AS to_hook_name,
    COUNT(*) AS to_count
  FROM cte__edges
  INNER JOIN cte__nodes
    ON cte__edges.to_concept = cte__nodes.concept
    AND cte__edges.to_keyset = cte__nodes.keyset
    AND cte__edges.to_hook = cte__nodes.hook
    AND (
      1 = 1
      AND cte__edges.frame <> cte__nodes.frame
      OR cte__edges.from_hook_name <> cte__nodes.hook_name
    )
  GROUP BY ALL
), cte__safe_sigs AS (
  SELECT
    cte__from_stats.from_frame,
    cte__from_stats.from_concept,
    cte__from_stats.from_keyset,
    cte__from_stats.from_hook_name,
    cte__to_stats.to_frame,
    cte__from_stats.to_concept,
    cte__from_stats.to_keyset,
    cte__to_stats.to_hook_name,
    cte__from_stats.from_count,
    cte__to_stats.to_count,
    cte__to_stats.to_count = cte__from_stats.from_count AS is_safe
  FROM cte__from_stats
  INNER JOIN cte__to_stats
    ON cte__to_stats.from_frame = cte__from_stats.from_frame
    AND cte__to_stats.from_concept = cte__from_stats.from_concept
    AND cte__to_stats.from_keyset = cte__from_stats.from_keyset
    AND cte__to_stats.from_hook_name = cte__from_stats.from_hook_name
    AND cte__to_stats.to_concept = cte__from_stats.to_concept
    AND cte__to_stats.to_keyset = cte__from_stats.to_keyset
  WHERE
    1 = 1 AND is_safe
)
SELECT
  cte__safe_sigs.from_frame,
  cte__safe_sigs.from_concept,
  cte__safe_sigs.from_keyset,
  cte__safe_sigs.from_hook_name,
  cte__edges.from_hook,
  cte__safe_sigs.to_frame,
  cte__safe_sigs.to_concept,
  cte__safe_sigs.to_keyset,
  cte__safe_sigs.to_hook_name,
  cte__edges.to_hook
FROM cte__safe_sigs
INNER JOIN cte__edges
  ON cte__safe_sigs.from_frame = cte__edges.frame
  AND cte__safe_sigs.from_concept = cte__edges.from_concept
  AND cte__safe_sigs.from_keyset = cte__edges.from_keyset
  AND cte__safe_sigs.from_hook_name = cte__edges.from_hook_name
  AND cte__safe_sigs.to_concept = cte__edges.to_concept
  AND cte__safe_sigs.to_keyset = cte__edges.to_keyset