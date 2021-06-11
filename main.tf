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

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.20.0"
    }
  }
}

provider "google" {
  credentials = file("terraform.json")
  project =  var.project
  region  =  var.region
  zone    =  var.zone
}

/*
locals {
  blueprint_cluster_master_name = "blueprint-cluster-master"
  zone    = var.zone == "" ? data.google_compute_zones.available.names[0] : var.zone
}


data "template_file" "blueprint_startup_script" {
  template = file(format("${path.module}/templates/startup_script.sh.tpl"))

  vars = {
    BLUEPRINT_CLUSTER_MASTER_NAME      = local.blueprint_cluster_master_name
    BLUEPRINT_ADMIN_PASSWORD           = var.blueprint_admin_password
    BLUEPRINT_CLUSTER_SECRET           = var.blueprint_cluster_secret
    BLUEPRINT_CM_PRIVATE_IP          = google_compute_address.blueprint_cluster_master_ip.address
  }

  depends_on = [
     google_compute_address.blueprint_cluster_master_ip,
  ]
}
*/

data "google_compute_zones" "available" {
    region = var.region
blueprint_cluster_master_name}
