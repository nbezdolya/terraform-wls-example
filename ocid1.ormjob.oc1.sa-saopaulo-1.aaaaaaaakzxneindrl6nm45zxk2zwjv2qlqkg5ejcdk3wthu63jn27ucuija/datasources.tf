/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}
data "oci_identity_tenancy" "tenancy" {
  #Required
  tenancy_id = "${var.tenancy_ocid}"
}
locals {
  num_ads = length(
    data.oci_identity_availability_domains.ADs.availability_domains,
  )
  is_single_ad_region = local.num_ads == 1 ? true : false
}
data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = ["${data.oci_identity_tenancy.tenancy.home_region_key}"]
  }
}
data "oci_core_instance" "existing_bastion_instance" {
  count = var.existing_bastion_instance_id != "" ? 1: 0

  instance_id = var.existing_bastion_instance_id
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
  template = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")
}


data "oci_core_subnet" "wls_subnet" {
  count = var.wls_subnet_id == "" ? 0 : 1

  #Required
  subnet_id = var.wls_subnet_id
}

data "oci_core_subnet" "bastion_subnet" {
  count = var.bastion_subnet_id == "" ? 0 : 1

  #Required
  subnet_id = var.bastion_subnet_id
}
# For querying availability domains given subnet_id
data "oci_core_subnet" "lb_subnet_1_id" {
  count = var.lb_subnet_1_id == "" ? 0 : 1

  #Required
  subnet_id = var.lb_subnet_1_id
}

data "oci_core_subnet" "lb_subnet_2_id" {
  count = var.lb_subnet_2_id == "" ? 0 : 1

  #Required
  subnet_id = var.lb_subnet_2_id
}