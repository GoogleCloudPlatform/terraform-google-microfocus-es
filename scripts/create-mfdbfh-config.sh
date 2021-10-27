#! /bin/bash
mfdbfh_cfg_path=$1
dbuser=$2
dbpassword=$3
. /opt/microfocus/EnterpriseDeveloper/bin/cobsetenv ""
cat <<EOT > $mfdbfh_cfg_path
<datastores>
  <server name="ESPacDatabase" type="postgresql" access="odbc">
    <dsn name="PG.POSTGRES" type="database" dbname="postgres" userid="$dbuser" password="$dbpassword"/>
    <dsn name="PG.VSAM" type="datastore" dsname="VSAM" userid="$dbuser" password="$dbpassword"/>
    <dsn name="PG.REGION" type="region.cas" region="DemoPAC" feature="all" userid="$dbuser" password="$dbpassword"/>
    <dsn name="PG.CROSSREGION" type="crossregion.cas" userid="$dbuser" password="$dbpassword"/>
  </server>
</datastores>
EOT

