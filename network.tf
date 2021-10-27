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

resource "google_compute_network" "vpc" {
  count                   = var.create_network ? 1 : 0
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  count                    = var.create_network ? 1 : 0
  name                     = "${var.name}-subnetwork"
  ip_cidr_range            = "${var.vpc_subnet_cidr}"
  region                   = var.region
  network                  = google_compute_network.vpc[0].id
  private_ip_google_access = true
}

module "private-service-access" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  project_id  = var.project_id
  vpc_network = var.create_network ? google_compute_network.vpc[0].name : var.vpc_network
  depends_on = [google_compute_network.vpc]
}

#lock ESCWA and TN3270 to source IP
resource "google_compute_firewall" "escwa" {
  name    = "${var.name}-firewall-rule-escwa"
  network = var.create_network ? google_compute_network.vpc[0].name : var.vpc_network
  allow {
    protocol = "tcp"
    ports    = ["10086", "5557"]
  }
  
  source_ranges=[var.ssh_ip]
}

#access to mfds, escwa and comms processes between ES instances and ESCWA instance
resource "google_compute_firewall" "esserver" {
  name    = "${var.name}-firewall-rule-esserver"
  network = var.create_network ? google_compute_network.vpc[0].name : var.vpc_network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1086", "10086", "5500-5600"]
  }
  
  #ES instances or load balancer
  source_tags = ["es", "allow-lb-service"]
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.name}-firewall-rule-ssh"
  network = var.create_network ? google_compute_network.vpc[0].name : var.vpc_network

  allow {
    protocol = "tcp"
    ports    = ["22","3389"]
  }
}

resource "google_compute_firewall" "activedirectory" {
  name    = "${var.name}-firewall-rule-activedirectory"
  network = var.create_network ? google_compute_network.vpc[0].name : var.vpc_network

  allow {
    protocol = "tcp"
    ports    = ["389"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["389"]
  }
}
