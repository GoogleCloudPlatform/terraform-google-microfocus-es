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

module "sql-db" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version = "6.0.0"
  name = "${var.name}-db"
  random_instance_name = true
  project_id = var.project_id
  database_version = "POSTGRES_12"
  availability_type = "REGIONAL"
  region = var.region
  zone = var.availability_zones[0]
  deletion_protection = false
  tier = "db-f1-micro"
  disk_autoresize  = false
  disk_size        = 100
  disk_type        = "PD_HDD"
  db_name      = var.pg_db_name
  db_charset   = "UTF8"
  db_collation = "en_US.UTF8"
  user_name = "mfdbfh"
  user_password = "a3db429bd0bb"
  database_flags = [{ name  = "max_connections", value = "10000" }]
  ip_configuration = {
    ipv4_enabled    = false
    require_ssl     = false
    private_network = google_compute_network.vpc.id
      authorized_networks = [
      {
        name  = google_compute_network.vpc.name
        value = var.pg_ha_external_ip_range
      },
    ]
  }

  read_replica_name_suffix = "-replica"
  read_replicas = [
    {
      name             = "0"
      zone             = var.availability_zones[1]
      tier             = "db-f1-micro"

      ip_configuration = {
        ipv4_enabled    = false
        require_ssl     = false
        private_network = google_compute_network.vpc.id
        authorized_networks = [
        {
          name  = google_compute_network.vpc.name
          value = var.pg_ha_external_ip_range
        },
        ]
      } 
      
      database_flags   = [{ name = "autovacuum", value = "off" }, { name  = "max_connections", value = "10000" }]
      disk_autoresize  = false
      disk_size        = 100
      disk_type        = "PD_HDD"
      user_labels      = { bar = "baz" }
    },
  ]
  
  
  backup_configuration = {
    enabled                        = true
    start_time                     = "00:55"
    location                       = null
    point_in_time_recovery_enabled = false
    transaction_log_retention_days = null
    retained_backups               = 365
    retention_unit                 = "COUNT"
  }
  
  depends_on = [
    module.private-service-access.peering_completed,
  ]
}