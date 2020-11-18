/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */
variable "compartment_ocid" {}

variable "vcn_name" {
  default = "wls-vcn"
}

//variable "cidr_block" {
//  default="10.0.0.0/16"
//}

variable "vcn_id" {
  type    = string
  default = ""
}

variable "wls_vcn_cidr" {}

variable "use_existing_subnets" {
  default = "false"
}

variable "defined_tags" {
  type=map
  default = {}
}

variable "freeform_tags" {
  type=map
  default = {}
}


variable "service_name_prefix" {

}
