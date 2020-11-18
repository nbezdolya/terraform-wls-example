/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */
variable "compartment_ocid" {}

variable "tenancy_ocid" {}

variable "subnet_ocids" {
  type = list
}

variable "instance_private_ips" {
  type = list
}

variable "shape" {
  default = "400Mbps"
}

variable "name" {
  default = "wls-loadbalancer"
}

variable "is_private" {
  default = "false"
}
variable "wls_ms_port" {}

variable "lb-protocol" {
  default = "HTTP"
}

variable "lb-lstr-port" {
  default = "80"
}

variable "lb-https-lstr-port" {
  default = "443"
}

variable "numVMInstances" {}

variable "return_code" {
  default = "404"
}

variable "policy_weight" {
  default = "1"
}

variable "add_load_balancer" {
  type = bool
}

variable "lb_backendset_name" {
  default = "wls-lb-backendset"
}

variable "lb_policy" {
  default = "ROUND_ROBIN"
}

variable "is_idcs_selected" {}

variable "idcs_cloudgate_port" {}

variable "defined_tags" {
  type=map
  default = {}
}

variable "freeform_tags" {
  type=map
  default = {}
}
variable "lb_certificate_name" {
  type = string
  default = "demo_cert"
}


variable "lbCount" {}

variable "allow_manual_domain_extension" {
  type = bool
}

variable "load_balancer_id" {
  type = string
  description = "ocid for load balancer"
}
