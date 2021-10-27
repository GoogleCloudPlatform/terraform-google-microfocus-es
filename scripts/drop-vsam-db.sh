dbusername=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/dbusername' -H 'Metadata-Flavor: Google')
dbpassword=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/dbpassword' -H 'Metadata-Flavor: Google')
echo drop database \"MicroFocus\$SEE\$Files\$VSAM\" | isql PG.POSTGRES $dbusername $dbpassword
