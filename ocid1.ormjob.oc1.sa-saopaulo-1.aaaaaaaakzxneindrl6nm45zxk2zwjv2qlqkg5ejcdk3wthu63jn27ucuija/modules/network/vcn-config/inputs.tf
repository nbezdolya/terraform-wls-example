/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */
variable "compartment_id" {
  type = string
}

variable "internet_gateway_destination" {
  default = "0.0.0.0/0"
}

variable "vcn_id" {}

variable "wls_vcn_name" {}

variable "existing_vcn_id" {}

variable "internet_gateway_name" {
  default = "wls-internet-gateway"
}

variable "security-list-name" {
  default = "wls-security-list"
}

variable "instance_private_ip" {
  default = "0.0.0.0"
}

variable "add_load_balancer" {
  type    = bool
  default = false
}

// Optional params

variable "dhcp_options_name" {
  default = "dhcpOptions"
}

variable "route_table_name" {
  default = "routetable"
}

variable "internet_gw_name" {
  default = "internet-gateway"
}

// Required params for LB security list
variable "lb_security_list_name" {
  default = "lb_security_list"
}

variable "is_lb_private" {
}

// Optional params

/*
Allow access to all ports to all VMs on the specified subnet CIDR
For LB backend subnet - an lb_additional_subnet_cidr will be = LB frontend subnet CIDR
This will open ports for LB backend subnet VMs to all VMs in its subnet and
in LB frontend subnet.

For LB frontend subnet - this is not passed.
*/

variable "wls_subnet_cidr" {}

variable "lb_subnet_1_cidr" {}

variable "lb_subnet_2_cidr" {}

// Optional params
variable "wls_admin_port" {
  default = "7001"
}

variable "wls_ssl_admin_port" {
  default = "7002"
}

variable "wls_ms_port" {
  default = "7003"
}

variable "wls_ms_ssl_port" {
  default = "7004"
}

variable "wls_security_list_name" {
  default = "wls-security-list"
}

variable "use_existing_subnets" {
  default = false
}

variable "service_name_prefix" {}

variable "nat_gateway_display_name" {
  default = "nat-gateway"
}

variable "assign_backend_public_ip" {
  default = "true"
}

variable "use_regional_subnets" {
  type    = bool
  default = false
}

variable "wls_bastion_security_list_name" {
  default = "wls-bastion-security-list"
}

variable "bastion_subnet_cidr" {
  default = ""
}

variable "is_bastion_instance_required" {
  type = bool
}

variable "existing_bastion_instance_id" {
  type = string
}

variable "is_single_ad_region" {}

variable "is_idcs_selected" {}

variable "idcs_cloudgate_port" {}

variable "is_vcn_peering" {}

variable "defined_tags" {
  type    = map
  default = {}
}

variable "freeform_tags" {
  type    = map
  default = {}
}
