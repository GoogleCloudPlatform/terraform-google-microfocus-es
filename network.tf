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
## VPC
####
resource "google_compute_network" "vpc_network" {
  count = var.create_network ? 1 : 0
  name                    = var.blueprint_network
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "blueprint_subnet" {
  count = var.create_network ? 1 : 0
  name = var.blueprint_subnet
  ip_cidr_range = var.blueprint_subnet_cidr
  region = var.region
  network = google_compute_network.vpc_network[0].self_link
}


resource "google_compute_global_forwarding_rule" "blueprint_cluster_rule" {
  name       = "splunk-shc-splunkweb-rule"
  target     = google_compute_target_http_proxy.blueprint_cluster_proxy.self_link
  ip_address = google_compute_global_address.blueprint_cluster_address.address
  port_range = "80"
}

resource "google_compute_global_address" "blueprint_cluster_address" {
  name = "splunk-shc-splunkweb-address"
}

resource "google_compute_target_http_proxy" "blueprint_cluster_proxy" {
  name    = "splunk-shc-splunkweb-proxy"
  url_map = google_compute_url_map.blueprint_cluster_url_map.self_link
}

resource "google_compute_url_map" "blueprint_cluster_url_map" {
  name            = "blueprintweb-url-map"
  default_service = google_compute_backend_service.default.self_link
}

resource "google_compute_backend_service" "default" {
  name      = "blueprint-web"
  port_name = "blueprintweb"
  protocol  = "HTTP"

  backend {
    group          = google_compute_region_instance_group_manager.blueprint_cluster.instance_group
    balancing_mode = "UTILIZATION"
  }

  health_checks = [google_compute_health_check.default.self_link]

  session_affinity        = "GENERATED_COOKIE"
  affinity_cookie_ttl_sec = "86400"
  enable_cdn              = true

  connection_draining_timeout_sec = "300"
}


####
## Firewall Rules
####
resource "google_compute_firewall" "allow_internal" {
  name    = "splunk-network-allow-internal"
  network = var.create_network ? google_compute_network.vpc_network[0].name : var.blueprint_network

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  source_tags = ["blueprint"]
  target_tags = ["blueprint"]
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "blueprint-network-allow-health-checks"
  network = var.create_network ? google_compute_network.vpc_network[0].name : var.blueprint_network

  allow {
    protocol = "tcp"
    ports    = ["8089", "8088"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["splunk"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "blueprint-network-allow-ssh"
  network = var.create_network ? google_compute_network.vpc_network[0].name : var.blueprint_network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["splunk"]
}

resource "google_compute_firewall" "allow_blueprint_web" {
  name    = "blueprint-network-allow-web"
  network = var.create_network ? google_compute_network.vpc_network[0].name : var.blueprint_network

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  target_tags = ["blueprint"]
}

####
## Health Checks
####
resource "google_compute_health_check" "default" {
  name                = "blueprint-health-check"
  check_interval_sec  = 15
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  tcp_health_check {
    port = "8089"
  }

  depends_on = [google_compute_firewall.allow_health_checks]
}
