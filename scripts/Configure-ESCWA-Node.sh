license_file_remote=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/license-file' -H 'Metadata-Flavor: Google')
redis_host=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/redishost' -H 'Metadata-Flavor: Google')
sqlhost=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/sqlhost' -H 'Metadata-Flavor: Google')
ESCount=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/escount' -H 'Metadata-Flavor: Google')
clusterPrefix=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/clusterPrefix' -H 'Metadata-Flavor: Google')
region=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/region' -H 'Metadata-Flavor: Google')
setup_folder=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/setup-folder' -H 'Metadata-Flavor: Google')
activedirectory_host=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/activedirectoryhost' -H 'Metadata-Flavor: Google')

usernameFull=demouser

echo "Downloading setup scripts"
gsutil cp "$setup_folder/*" .
chmod u+x *.sh

./install-license.sh $license_file_remote
./start-mfds.sh $usernameFull
./install-odbc-dsns.sh $sqlhost
./start-escwa.sh $usernameFull

yum install -y python3
python3 -m pip install requests
python3 createpac.py "http://localhost:10086" $redis_host $region $clusterPrefix-es-mig

./import-region-bankdemo.sh $usernameFull BankDemo_PAC.zip /home/$usernameFull
export MFDBFH_CONFIG=/home/$usernameFull/BankDemo_PAC/System/MFDBFH.cfg
./create-mfdbfh-config.sh $MFDBFH_CONFIG a3db429bd0bb
./deploy-datafiles.sh /home/$usernameFull
service firewalld stop

#configure ESCWA to secure against active directory
#empty username uses default CN=MFReader,CN=ADAM Users,CN=Micro Focus,CN=Program Data,DC=local
python3 secure-escwa.py http://localhost:10086 $activedirectory_host "" "mf_rdr7_3_1"