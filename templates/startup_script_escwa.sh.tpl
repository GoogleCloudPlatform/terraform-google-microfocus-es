#!/bin/bash
#
# Copyright 2019 Google LLC
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
set -x
log() { 
  echo "`date`: $1"; 
  curl -X PUT --data "$1" http://metadata.google.internal/computeMetadata/v1/instance/guest-attributes/blueprint/install-status -H "Metadata-Flavor: Google"
}

export BLUEPRINT_USER=blueprint
export BLUEPRINT_BIN=/opt/blueprint/bin/blueprint
export BLUEPRINT_HOME=/opt/blueprint
export BLUEPRINT_ROLE="$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/blueprint-role -H "Metadata-Flavor: Google")"
export LOCAL_IP="$(curl http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip -H "Metadata-Flavor: Google")"

curl -X PUT --data "in-progress" http://metadata.google.internal/computeMetadata/v1/instance/guest-attributes/blueprint/install -H "Metadata-Flavor: Google"

usernameFull=demouser

echo "Downloading setup scripts"
gsutil cp "${BUCKET_URL}/*" .
chmod u+x *.sh

#block incoming traffic
firewall-cmd --zone=public --change-interface=eth0

./install-license.sh "${LICENSE_FILENAME}"
./start-mfds.sh $usernameFull
./install-odbc-dsns.sh
./start-escwa.sh $usernameFull

yum install -y python3
python3 -m pip install requests
python3 createpac.py "http://localhost:10086" ${REDIS_HOST} ${REGION} ${CLUSTER_PREFIX}-es-mig

./import-region-bankdemo.sh $usernameFull BankDemo_PAC.zip /home/$usernameFull
echo "Setting up cloud SQL proxy"
./setup-cloudsql-proxy.sh "${SQL_CONNECTION}"
export MFDBFH_CONFIG=/home/$usernameFull/BankDemo_PAC/System/MFDBFH.cfg
echo "Creating $MFDBFH_CONFIG"
./create-mfdbfh-config.sh $MFDBFH_CONFIG ${SQL_USERNAME} ${SQL_PASSWORD}
echo "Deploying data files"
./deploy-datafiles.sh /home/$usernameFull

#configure ESCWA to secure against active directory
#empty username uses default CN=MFReader,CN=ADAM Users,CN=Micro Focus,CN=Program Data,DC=local
python3 secure-escwa.py http://localhost:10086 ${AD_HOST} "" "mf_rdr7_3_1"

#allow remote ESCWA connection
sudo firewall-cmd --zone=public --add-port=10086/tcp --permanent
sudo firewall-cmd --reload