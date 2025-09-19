MODEL (
  name raw.@name,
  enabled TRUE,
  kind VIEW,
  blueprints (
    (name := customer),
    (name := lineitem),
    (name := nation),
    (name := orders),
    (name := part),
    (name := partsupp),
    (name := region),
    (name := supplier),
  )
);

SELECT
  *
FROM main.@{name}