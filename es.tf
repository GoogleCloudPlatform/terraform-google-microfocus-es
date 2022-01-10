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

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = ">= 7.3.0"
  project_id      = var.project_id
  name_prefix     = "esvm"
  service_account = var.vm_service_account
  subnetwork = var.create_network ? module.vpc[0].subnets_names[0] : var.vpc_subnet
  subnetwork_project = var.project_id
  machine_type    = var.vm_machine_type
  region          = var.region
  //ED7.0 image
  source_image_project = var.es_image_project
  source_image_family = ""
  source_image = var.es_image_name
  auto_delete = true
  
  metadata = {
    startup-script = data.template_file.es_startup_script.rendered
  }
  
  #Empty access_config causes an external IP to be auto-assigned
  access_config = [{
    nat_ip=""
    network_tier="STANDARD"
  }]
  depends_on = [null_resource.upload_folder_content]
  tags=["es"]
}

module "mig" {
  source                    = "terraform-google-modules/vm/google//modules/mig"
  version = ">= 7.3.0"
  instance_template         = module.instance_template.self_link
  region                    = var.region
  project_id                = var.project_id
  hostname                  = "${var.name}-es"
  distribution_policy_zones = [var.availability_zones[0], var.availability_zones[1]]
  target_size               = var.escount
  target_pools              = [module.load_balancer.target_pool]
  wait_for_instances        = true
}
