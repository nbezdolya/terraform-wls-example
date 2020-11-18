/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

/**
* Network related variables
*/

variable "wls_vcn_name" {
  default = ""
}

variable "wls_existing_vcn_id" {
  default = ""
}


variable "wls_availability_domain_name" {
  type        = string
  default     = ""
  description = "availablility domain for weblogic vm instances"
}

// Specify an LB AD 1 if lb is requested
variable "lb_subnet_1_availability_domain_name" {
  type        = string
  default = ""
  description = "availablility domain for load balancer"
}

// Specify an LB AD 2 if lb is requested
variable "lb_subnet_2_availability_domain_name" {
  type        = string
  default = ""
  description = "availablility domain for load balancer"
}

variable "wls_vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "add_load_balancer" {
  type = bool
  default = false
}

variable "wls_subnet_name" {
  default = "wls-subnet"
}

variable "wls_subnet_cidr" {
  default = ""
}

variable "lb_subnet_1_name" {
  default = "lb-subnet-1"
}

variable "lb_subnet_1_cidr" {
  default = ""
}

variable "lb_subnet_2_name" {
  default = "lb-subnet-2"
}

variable "lb_subnet_2_cidr" {
  default = ""
}

variable "use_regional_subnet" {
  type = bool
  default = true
}

variable "volume_name" {
  default = ""
}

variable "assign_weblogic_public_ip" {
  default = "true"
}

variable "bastion_subnet_cidr" {
  default = ""
}

variable "bastion_subnet_name" {
  default = "bsubnet"
}

variable "wls_subnet_id" {
  default = ""
}

variable "is_bastion_instance_required" {
  default = true
}

# existing bastion instance support
variable "existing_bastion_instance_id" {
  type    = string
  default = ""
}

variable "bastion_ssh_private_key" {
  type    = string
  default = ""
}

variable "lb_subnet_1_id" {
  default = ""
}

variable "lb_subnet_2_id" {
  default = ""
}

variable "bastion_subnet_id" {
  default = ""
}

variable "lb_shape" {
  default = "400Mbps"
}

variable "is_lb_private" {
  default = "false"
}

/*
********************
Local VCN Peering Parameters
********************
*/
// If criteria for VCN peering is met and this feature flag is set, only then VCN peering will be done.
variable "use_local_vcn_peering" {
  default = "true"
}

variable "wls_dns_subnet_cidr" {
  default = ""
}

variable "ocidb_dns_subnet_cidr" {
  default = ""
}

variable "dns_instance_shape" {
  default = ""
}

