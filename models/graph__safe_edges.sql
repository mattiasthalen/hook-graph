MODEL (
  name graph.safe_edges,
  kind VIEW,
  enabled TRUE
);

WITH cte__edges AS (
  SELECT *
  FROM graph.edges
),

cte__from_stats AS (
  SELECT
      frame                       AS from_frame,
      from_concept,
      from_keyset,
      from_hook_name,
      to_concept,
      to_keyset,
      COUNT(*)                    AS from_count
  FROM cte__edges
  GROUP BY ALL
),

cte__to_stats AS (
  SELECT
      src.frame                   AS from_frame,
      src.from_concept,
      src.from_keyset,
      src.from_hook_name,
      dst.frame                   AS to_frame,
      src.to_concept,
      src.to_keyset,
      dst.from_hook_name          AS to_hook_name,
      COUNT(*)                    AS to_count
  FROM cte__edges AS src
  INNER JOIN cte__edges AS dst
    ON  src.to_hook    = dst.from_hook
    AND src.to_concept = dst.from_concept
    AND src.to_keyset  = dst.from_keyset
  GROUP BY ALL
),

cte__safe_sigs AS (
  SELECT
      fs.from_frame,
      fs.from_concept,
      fs.from_keyset,
      fs.from_hook_name,
      ts.to_frame,
      fs.to_concept,
      fs.to_keyset,
      ts.to_hook_name
  FROM cte__from_stats AS fs
  INNER JOIN cte__to_stats AS ts
    ON  ts.from_frame     = fs.from_frame
    AND ts.from_concept   = fs.from_concept
    AND ts.from_keyset    = fs.from_keyset
    AND ts.from_hook_name = fs.from_hook_name
    AND ts.to_concept     = fs.to_concept
    AND ts.to_keyset      = fs.to_keyset
  WHERE ts.to_count <= fs.from_count
)

SELECT DISTINCT
    ss.from_frame,
    ss.from_concept,
    ss.from_keyset,
    ss.from_hook_name,
    e.from_hook,
    ss.to_frame,
    ss.to_concept,
    ss.to_keyset,
    ss.to_hook_name,
    e.to_hook
FROM cte__safe_sigs AS ss
INNER JOIN cte__edges AS e
  ON  e.frame          = ss.from_frame
  AND e.from_concept   = ss.from_concept
  AND e.from_keyset    = ss.from_keyset
  AND e.from_hook_name = ss.from_hook_name
  AND e.to_concept     = ss.to_concept
  AND e.to_keyset      = ss.to_keyset;