license_filename=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/license-filename' -H 'Metadata-Flavor: Google')
redis_host=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/redishost' -H 'Metadata-Flavor: Google')
sqlhost=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/sqlhost' -H 'Metadata-Flavor: Google')
setup_folder=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/setup-folder' -H 'Metadata-Flavor: Google')
dbusername=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/dbusername' -H 'Metadata-Flavor: Google')
dbpassword=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/dbpassword' -H 'Metadata-Flavor: Google')

echo "Downloading setup scripts"
gsutil cp "$setup_folder/*" .
chmod u+x *.sh

usernameFull=demouser

./install-license.sh $license_filename
./start-mfds.sh $usernameFull
./import-region-bankdemo.sh $usernameFull BankDemo_PAC.zip /home/$usernameFull
export MFDBFH_CONFIG=/home/$usernameFull/BankDemo_PAC/System/MFDBFH.cfg
./create-mfdbfh-config.sh $MFDBFH_CONFIG $dbusername $dbpassword
./install-odbc-dsns.sh $sqlhost
./start-escwa.sh $usernameFull
./escwa-login.sh
./escwa-delete-default-directoryserver.sh
./escwa-add-directoryserver.sh localhost 1086 localhost

./escwa-set-xadef.sh PG.VSAM /home/demouser/BankDemo_PAC/xa/ESODBCXA64.so mfdbfh a3db429bd0bb
