MODEL (
  name scd.@name,
  enabled TRUE,
  kind SCD_TYPE_2_BY_COLUMN (
    unique_key @unique_key,
    columns *,
    invalidate_hard_deletes TRUE,
    valid_from_name record__valid_from,
    valid_to_name record__valid_to
  ),
  blueprints (
    (name := demographics, unique_key := (id, customer_id)),
    (name := items, unique_key := (id, ds)),
    (name := marketing, unique_key := (id, customer_id)),
    (name := order_items, unique_key := (id, ds)),
    (name := orders, unique_key := (id, ds)),
    (name := waiter_names, unique_key := id)
  )
);

SELECT
  *
FROM raw.@{name}