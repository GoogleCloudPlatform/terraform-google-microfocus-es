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
      version = "3.70.0"
    }
  }
}

provider "google" {
#credentials = file("terraform.json")
  project = var.project_id
  region  = var.region
  zone    = var.availability_zones[0]
}

data "template_file" "es_startup_script" {
  template = file(format("${path.module}/templates/startup_script_es.sh.tpl"))
  vars = {
    LICENSE_FILENAME  = var.license_filename
    BUCKET_URL        = module.storage.bucket.url
    SQL_CONNECTION    = module.sql-db.instance_connection_name
    SQL_HOST          = module.sql-db.private_ip_address
    SQL_USERNAME      = var.pg_db_username
    SQL_PASSWORD      = var.pg_db_password
  }
    
  depends_on = [
  ]
}

data "template_file" "escwa_startup_script" {
  template = file(format("${path.module}/templates/startup_script_escwa.sh.tpl"))
  vars = {
    LICENSE_FILENAME  = var.license_filename
    BUCKET_URL        = module.storage.bucket.url
    REDIS_HOST        = module.memcache.host
    SQL_CONNECTION    = module.sql-db.instance_connection_name
    SQL_HOST          = module.sql-db.private_ip_address
    SQL_USERNAME      = var.pg_db_username
    SQL_PASSWORD      = var.pg_db_password
    AD_HOST           = "${var.name}-activedirectory-001"
    CLUSTER_PREFIX    = var.name
    REGION            = var.region
  }
    
  depends_on = [
  ]
}