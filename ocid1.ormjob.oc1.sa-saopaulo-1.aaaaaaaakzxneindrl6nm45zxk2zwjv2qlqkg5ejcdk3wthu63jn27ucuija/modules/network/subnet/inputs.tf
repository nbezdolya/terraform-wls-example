/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */

variable "compartment_ocid" {
  type = string
}

variable "availability_domain" {
  type = string
}

variable "tenancy_ocid" {
  type = string
}

variable "dns_label" {
  type = string
}
variable "vcn_id" {
  type = string
}

variable "subnetCount" {
  default = "1"
}

variable "security_list_id" {
  type = list
}

variable "dhcp_options_id" {
  type = string
}

variable "route_table_id" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "subnet_name" {
  default = "wls-subnet"
}

variable "add_load_balancer" {
  default = "false"
}

variable "is_vcn_peered" {
  default = "false"
}

variable "prohibit_public_ip" {
  default = "false"
}

//if existing subnet is used
variable "subnet_id" {
  default = ""
}

variable "use_existing_subnets" {
  default = "false"
}

variable "use_regional_subnet" {
  type = bool
  default = true
}

variable "defined_tags" {
  type=map
  default = {}
}

variable "freeform_tags" {
  type=map
  default = {}
}