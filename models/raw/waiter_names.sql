MODEL (
  name raw.waiter_names,
  kind SEED (
    path '../../seeds/waiter_names.csv'
  ),
  columns (
    id INT,
    name TEXT
  ),
  grain "id"
);
