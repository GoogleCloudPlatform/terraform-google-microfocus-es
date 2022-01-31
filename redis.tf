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

resource "google_redis_instance" "redis" {
  name           = "${var.name}-redis"
  tier           = "STANDARD_HA"
  memory_size_gb = var.redis_memory_size_gb
  location_id             = var.availability_zones[0]
  alternative_location_id = var.availability_zones[1]
  authorized_network = var.create_network ? module.vpc[0].network_name : var.vpc_network 
  redis_version     = "REDIS_6_X"
  display_name      = "${var.name}-redis"
  replica_count     = 1
  read_replicas_mode = "READ_REPLICAS_ENABLED"
}