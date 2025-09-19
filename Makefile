seed-data:
	duckcli data.duckdb --execute "CALL dbgen(sf=1);"