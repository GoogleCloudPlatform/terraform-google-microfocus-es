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
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name                     = "${var.name}-subnetwork"
  ip_cidr_range            = "10.2.0.0/16"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

module "private-service-access" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  project_id  = var.project_id
  vpc_network = google_compute_network.vpc.name
  depends_on = [google_compute_network.vpc]
}

#lock ESCWA and ES access to source IP
resource "google_compute_firewall" "default" {
  name    = "${var.name}-firewall-rule-escwa"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1086", "10086", "5557"]
  }
  
  source_ranges=[var.ssh_ip]
  
  #or to es instances
  source_tags = ["es", "allow-lb-service"]
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.name}-firewall-rule-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22","3389"]
  }
}

resource "google_compute_firewall" "activedirectory" {
  name    = "${var.name}-firewall-rule-activedirectory"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["389"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["389"]
  }
}