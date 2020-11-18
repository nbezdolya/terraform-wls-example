# Copyright 2020, Oracle Corporation and/or affiliates.  All rights reserved.

variable "tenancy_id" {}

variable "compartment_id" {}

variable "label_prefix" {}

variable "create_policies" {
  type = bool
  default = true
}

variable "add_loadbalancer" {
  type = bool
}

variable "atp_db" {
  type = object({
    is_atp = bool
    compartment_id = string
  })
}

//Add security list to existing db vcn
variable "ocidb_existing_vcn_add_seclist" {
  type = bool
}

//DB System Network Compartment
variable "ocidb_network_compartment_id" {}

#wlsc network compartment
variable "network_compartment_id" {}