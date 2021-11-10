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

