/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */

locals {
  dns_label = replace(var.dns_label,"-","")
}

data "oci_core_vcns" "wls_vcn" {
  #Required
  compartment_id = var.compartment_ocid

  #Optional
  filter {
    name   = "id"
    values = [var.vcn_id]
  }
}

resource "oci_core_subnet" "wls-subnet" {
  count                      = var.subnetCount
  availability_domain        = var.use_regional_subnet?"":var.availability_domain
  cidr_block                 = var.cidr_block
  display_name               = var.use_regional_subnet? var.subnet_name: format("%s-%s", var.subnet_name,var.availability_domain)
  dns_label                  = local.dns_label
  compartment_id             = var.compartment_ocid
  vcn_id                     = var.vcn_id
  security_list_ids          = var.security_list_id
  # Dont attach the route table for peered vcn here. It will be done in VCN peering module after LPG is created.
  route_table_id             = !var.is_vcn_peered ? var.route_table_id : ""
  dhcp_options_id            = var.is_vcn_peered =="true" ? lookup(data.oci_core_vcns.wls_vcn.virtual_networks[0], "default_dhcp_options_id") : var.dhcp_options_id
  prohibit_public_ip_on_vnic = var.prohibit_public_ip

  defined_tags               = var.defined_tags
  freeform_tags              = var.freeform_tags
}