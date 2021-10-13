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

project_id = "amc-marketplacegcp-nonprod"
name = "testjs2"
region = "europe-west2"
availability_zones = [
  "europe-west2-a",
  "europe-west2-b",
]

es_image_project = "artful-reef-327010"
es_image_name = "es70bankdemo"
ad_image_name = "adbankdemo"
escount = 2
vm_machine_type = "e2-standard-4"

storage_setup_folder = "gs://jsbucket1/folder1"
storage_license_path = "gs://jsbucket1/folder1/license.mflic"

ssh_ip = "146.200.27.215"