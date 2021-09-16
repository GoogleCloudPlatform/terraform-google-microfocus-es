license_file_remote=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/license-file' -H 'Metadata-Flavor: Google')
redis_host=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/redishost' -H 'Metadata-Flavor: Google')
sqlhost=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/sqlhost' -H 'Metadata-Flavor: Google')
setup_folder=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/setup-folder' -H 'Metadata-Flavor: Google')

echo "Downloading setup scripts"
gsutil cp "$setup_folder/*" .
chmod u+x *.sh

usernameFull=demouser

./install-license.sh $license_file_remote
./start-mfds.sh $usernameFull
./import-region-bankdemo.sh $usernameFull BankDemo_PAC.zip /home/$usernameFull
export MFDBFH_CONFIG=/home/$usernameFull/BankDemo_PAC/System/MFDBFH.cfg
./create-mfdbfh-config.sh $MFDBFH_CONFIG a3db429bd0bb
./install-odbc-dsns.sh $sqlhost
./install-xa.sh
./start-escwa.sh $usernameFull
./escwa-login.sh
./escwa-delete-default-directoryserver.sh
./escwa-add-directoryserver.sh localhost 1086 localhost

./escwa-set-xadef.sh PG.VSAM /home/demouser/BankDemo_PAC/xa/ESODBCXA64.so mfdbfh a3db429bd0bb
