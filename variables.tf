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

variable "project_id" {
  description = "The project to deploy the environment into"
  type        = string
}

variable "name" {
  description = "The prefix to use for created resources"
  type        = string
  default     = null
}

variable "region" {
  description = "Region to deploy to"
  type    = string
  default = "europe-west2"
}

variable "availability_zones" {
  description = "Availabity zones to use"
  type    = list(string)
  default = ["europe-west2-a", "europe-west2-b"]
}

variable "vm_service_account" {
  default = {
    email  = ""
    scopes = ["storage-ro", "compute-ro"]
  }
  type = object({
    email  = string
    scopes = set(string)
  })
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account."
}

variable "redis_memory_size_gb" {
  description = "Redis memory size in GiB. Defaulted to 1 GiB"
  type        = number
  default     = 1
}

variable "vm_machine_type" {
  description = "Machine type to use for Enteprise Server machines and ESCWA machine"
  type    = string
  default = "e2-micro"
}

variable "escount" {
  description = "Number of Enterprise Server instances to deploy"
  type    = number
  default = 2
}

variable "storage_license_path" {
  description = "Path of Enterprise Server license file"
  type    = string
  default = "gs://bucketname/folder/Enterprise-Developer-UNIX.mflic"
}

variable "storage_setup_folder" {
  description = "Path of storage folder containing setup scripts"
  type    = string
  default = "gs://bucketname/folder/scripts"
}

variable "es_image_project" {
  description = "Name of project containing Enterprise Server and Active Directory machine images"
  type    = string
  default = ""
}

variable "es_image_name" {
  description = "Name of Enterprise Server machine image"
  type    = string
  default = ""
}

variable "ad_image_name" {
  description = "Name of Active Directory machine image"
  type    = string
  default = "adlds2"
}

variable "ssh_ip" {
  description = "Access to the ESCWA endpoint will be restricted to this public IP address"
  type    = string
  default = ""
}

variable "pg_db_name" {
  type    = string
  default = "postgresql"
}

variable "pg_ha_external_ip_range" {
  type        = string
  description = "The ip range to allow connecting from/to Cloud SQL"
  default     = "192.10.10.10/32"
}