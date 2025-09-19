seed-data:
	duckcli tpch.duckdb --execute "CALL dbgen(sf=1);"