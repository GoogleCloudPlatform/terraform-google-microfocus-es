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


####
##  Blue Print VM's
####
resource "google_compute_instance_template" "blueprint_vm_template" {
  name_prefix  = "blueprint-vm-template-"
  machine_type = "n1-standard-4"

  tags = ["blueprint"]

  # boot disk
  disk {
    source_image = "ubuntu-os-cloud/ubuntu-1604-lts"
    disk_type    = "pd-ssd"
    disk_size_gb = "50"
    boot         = "true"
  }

  network_interface {
    network = var.create_network ? google_compute_network.vpc_network[0].self_link : var.blueprint_network
    subnetwork = var.create_network ? google_compute_subnetwork.blueprint_subnet[0].self_link : var.blueprint_subnet
    access_config {
      # Ephemeral IP
    }
  }

  metadata = {
#    startup-script = data.template_file.blueprint_startup_script.rendered
    blueprint-role    = "SHC-Member"
    enable-guest-attributes = "TRUE"
  }
}

resource "google_compute_region_instance_group_manager" "blueprint_cluster" {
  provider           = google
  name               = "blueprint-mig"
  region             = var.region
  base_instance_name = "blueprint-vm"

  target_size = var.blueprint_cluster_size

  version {
    name              = "blueprint-mig-version-0"
    instance_template = google_compute_instance_template.blueprint_vm_template.self_link
  }

  named_port {
    name = "blueprintweb"
    port = "8000"
  }

  depends_on = [
    google_compute_instance_template.blueprint_vm_template
  ]
}

