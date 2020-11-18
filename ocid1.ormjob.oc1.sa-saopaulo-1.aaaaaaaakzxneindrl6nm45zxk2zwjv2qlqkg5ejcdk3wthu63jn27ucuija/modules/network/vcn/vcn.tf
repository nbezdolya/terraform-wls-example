/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */
resource "oci_core_virtual_network" "wls-vcn" {
  // If vcn_name is provided and existing subnets are not used then we create VCN regardless of existing vcn_id value.
  // So vcn_name has preference.
  // If user wants to use existing vcn_id, then don't provide vcn_name and new VCN won't be created.
  count = var.vcn_name !="" && var.use_existing_subnets==false ? 1:0

  cidr_block     = var.wls_vcn_cidr
  dns_label      = "${var.service_name_prefix}vcn"
  compartment_id = var.compartment_ocid
  display_name   = "${var.service_name_prefix}-${var.vcn_name}"

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}
