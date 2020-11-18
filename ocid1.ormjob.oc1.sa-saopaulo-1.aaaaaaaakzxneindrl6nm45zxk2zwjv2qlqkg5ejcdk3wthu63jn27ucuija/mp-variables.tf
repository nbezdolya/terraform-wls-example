/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

variable "mp_baselinux_instance_image_id" {
  default = "ocid1.image.oc1..aaaaaaaatbokpfj2x3oio7ibv7tuzl3twuqpfeuwq4xcy4xr6hekjzuccuza"
}

variable "mp_baselinux_listing_id" {
  default = "ocid1.appcataloglisting.oc1..aaaaaaaacicjx6jviqczqow567tadr5ju7iy2m4vx6opyra6thql55n2nnvq"
}

variable "mp_baselinux_listing_resource_version" {
  default = "19.3.3-190816034153"
}

/*
********************
Marketplace UI Parameters
********************
*/
# Controls if we need to subscribe to marketplace PIC image and accept terms & conditions - defaults to true
variable "use_marketplace_image" {
default = "true"
}

variable "mp_listing_id" {
default = "ocid1.appcataloglisting.oc1..aaaaaaaawd5ti5ldjzdppppi675onvo3mvjcwt64jjey7rib3beau2ngkl2q"
}

variable "mp_listing_resource_version" {
default = "20.3.2-200824152337"
}

# Used in UI instead of assign_weblogic_public_ip
variable "subnet_type" {
  default = "Use Public Subnet"
}

# Used in UI instead of use_regional_subnet
variable "subnet_span" {
  default = "Regional Subnet"
}

variable "vcn_strategy" {
  default = ""
}

variable "subnet_strategy_existing_vcn" {
  default = ""
}

variable "subnet_strategy_new_vcn" {
  default = ""
}

variable "db_strategy" {
  default = "No Database"
}

variable "use_advanced_wls_instance_config" {
  default = "false"
}
