import duckdb
duckdb.connect(database='data.duckdb').execute("CALL dbgen(sf=1);")