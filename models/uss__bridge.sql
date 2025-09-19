MODEL (
  name uss._bridge,
  enabled FALSE,
  kind VIEW
);

WITH RECURSIVE
cte__safe_edges AS (
  SELECT *
  FROM graph.safe_edges
), cte__origin AS (
  SELECT DISTINCT
      from_frame  AS origin_frame,
      from_hook  AS origin_hook,
      from_frame   AS frame,
      from_concept AS concept,
      from_keyset  AS keyset,
      from_hook_name AS hook_name,
      from_hook      AS hook,
      0 AS depth,
      list_value(from_frame||'.'||from_hook_name) AS visited_keys
  FROM cte__safe_edges
), cte__walk AS (
  SELECT
      from_frame AS origin_frame,
        from_hook AS origin_hook,
      to_frame AS frame,
      to_concept AS concept,
      to_keyset AS keyset,
      to_hook_name AS hook_name,
      to_hook AS hook,
      1 AS depth,
      list_value(
        from_frame||'.'||from_hook_name,
        to_frame||'.'||to_hook_name
      )  AS visited_keys
  FROM cte__safe_edges

  UNION ALL

  SELECT
      cte__walk.origin_frame,
      cte__walk.origin_hook,
      cte__safe_edges.to_frame AS frame,
      cte__safe_edges.to_concept AS concept,
      cte__safe_edges.to_keyset AS keyset,
      cte__safe_edges.to_hook_name AS hook_name,
      cte__safe_edges.to_hook AS hook,
      cte__walk.depth + 1 AS depth,
      list_append(
        cte__walk.visited_keys,
        cte__safe_edges.to_frame || '|' || cte__safe_edges.to_hook_name
      ) AS visited_keys
  FROM cte__walk
  JOIN cte__safe_edges
    ON cte__safe_edges.from_concept = cte__walk.concept
   AND cte__safe_edges.from_keyset  = cte__walk.keyset
   AND cte__safe_edges.from_hook    = cte__walk.hook
 WHERE NOT list_contains(cte__walk.visited_keys, cte__safe_edges.to_frame || '|' || cte__safe_edges.to_hook_name)
), cte__union AS (
  SELECT
    origin_frame,
    origin_hook,
    hook_name,
    hook
  FROM cte__origin
  UNION ALL
  SELECT
    origin_frame,
    origin_hook,
    hook_name,
    hook
  FROM cte__walk
), cte__pivot AS (
  SELECT *
  FROM (
      PIVOT cte__union
      ON hook_name
      USING any_value(hook)
      GROUP BY origin_frame, origin_hook
  ) pvt
)

SELECT
  origin_frame AS peripheral,
  * EXCLUDE(origin_frame, origin_hook)
FROM cte__pivot