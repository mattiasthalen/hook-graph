seed:
	uv run seed_data.py

plan:
	uv run sqlmesh plan

seed-and-plan: seed plan
