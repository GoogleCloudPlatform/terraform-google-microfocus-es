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

module "escwa_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "6.5.0"
  project_id      = var.project_id
  name_prefix     = "escwa"
  service_account = var.vm_service_account
  subnetwork      = google_compute_subnetwork.vpc_subnetwork.name
  machine_type    = var.vm_machine_type
  
  //ED7.0 image
  source_image_project = var.es_image_project
  source_image_family = ""
  source_image = var.es_image_name
  auto_delete = true
  
  metadata = {
     startup-script-url = "${var.storage_setup_folder}/Configure-ESCWA-Node.sh" //"gs://bucket/folder/Configure-ESCWA-Node.sh"
     shutdown-script = "/drop-vsam-db.sh"
     setup-folder = var.storage_setup_folder
     license-file = var.storage_license_path                               //"gs://bucket/folder/license.mflic"
     redishost = module.memcache.host
     sqlhost = module.sql-db.private_ip_address
     escount = var.escount
     clusterPrefix = var.name
     region = var.region
     activedirectoryhost = "${var.name}-activedirectory-001"
  }
  
  tags=["es"]
  depends_on = [module.activedirectory_compute_instance]
}

module "compute_instance" {
  source            = "terraform-google-modules/vm/google//modules/compute_instance"
  region            = var.region
  zone              = var.availability_zones[0]
  subnetwork        = google_compute_subnetwork.vpc_subnetwork.name
  num_instances     = 1
  hostname          = "${var.name}-escwa"
  instance_template = module.escwa_instance_template.self_link
  
  #Empty access_config causes an external IP to be auto-assigned
  access_config = [{
    nat_ip=""
    network_tier="STANDARD"
  }]

  depends_on = [module.mig]
}
