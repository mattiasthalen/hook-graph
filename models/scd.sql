MODEL (
  name scd.@name,
  enabled TRUE,
  kind SCD_TYPE_2_BY_COLUMN (
    unique_key @source_grain,
    columns *,
    invalidate_hard_deletes TRUE,
    valid_from_name record__valid_from,
    valid_to_name record__valid_to
  ),
  grains @target_grain,
  blueprints (
    (name := demographics, source_grain := (id, customer_id), target_grain := (id, customer_id, record__valid_from)),
    (name := items, source_grain := (id, ds), target_grain := (id, ds, record__valid_from)),
    (name := marketing, source_grain := (id, customer_id), target_grain := (id, customer_id, record__valid_from)),
    (name := order_items, source_grain := (id, ds), target_grain := (id, ds, record__valid_from)),
    (name := orders, source_grain := (id, ds), target_grain := (id, ds, record__valid_from)),
    (name := waiter_names, source_grain := id, target_grain := (id, record__valid_from))
  )
);

SELECT
  *
FROM raw.@{name}