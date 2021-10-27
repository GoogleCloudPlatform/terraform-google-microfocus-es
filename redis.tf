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

module "memcache" {
  source         = "terraform-google-modules/memorystore/google"
  version = "3.0.0"
  name = "${var.name}-redis"
  project = var.project_id
  authorized_network = var.create_network ? google_compute_network.vpc[0].name : var.vpc_network
  redis_version     = "REDIS_5_0"
  memory_size_gb = var.redis_memory_size_gb
  enable_apis    = true
  region = var.region
}
