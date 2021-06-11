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

#Installation steps...
