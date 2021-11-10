#configure odbc DSNs
cat <<EOT >> /tmp/odbc.ini
[PG.VSAM]
Driver = PostgreSQL
Servername = localhost
port = 5432
Database = MicroFocus\$SEE\$Files\$VSAM

[PG.POSTGRES]
Driver = PostgreSQL
Servername = localhost
port = 5432
Database = postgres

[PG.REGION]
Driver = PostgreSQL
Servername = localhost
port = 5432
Database = MicroFocus\$CAS\$Region\$DEMOPAC

[PG.CROSSREGION]
Driver = PostgreSQL
Servername = localhost
port = 5432
Database = MicroFocus\$CAS\$CrossRegion
EOT

odbcinst -i -s -l -f /tmp/odbc.ini
