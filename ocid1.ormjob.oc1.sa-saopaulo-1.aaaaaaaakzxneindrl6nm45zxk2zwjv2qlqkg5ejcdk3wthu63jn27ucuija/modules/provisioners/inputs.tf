/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */
variable "ssh_private_key" {
  type = string
}

variable "host_ips" {
  type = list
}

variable "numVMInstances" {}

variable "is_atp_db" {
  default = "false"
}

variable "atp_db_id" {
  default = ""
}

variable "atp_db_name" {
  default = ""
}

variable "mode" {}


variable "db_port" {
  default = "1521"
}

variable "bastion_host" {
  default = ""
}

variable "bastion_host_private_key" {
  default = ""
}

variable "assign_public_ip" {
  default = "true"
}

variable "is_bastion_instance_required" {
  type = bool
  default = true
}

variable "existing_bastion_instance_id" {
  type        = string
}

variable "oracle_key" {
  type = map
}

variable "atp_policy_id" {
  type = string
}

variable "secrets_policy_id" {
  type = string
}
