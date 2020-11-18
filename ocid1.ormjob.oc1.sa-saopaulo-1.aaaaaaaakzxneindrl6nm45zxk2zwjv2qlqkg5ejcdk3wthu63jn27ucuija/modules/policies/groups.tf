# Copyright 2020, Oracle Corporation and/or affiliates.  All rights reserved.


locals {
  compartment = format("instance.compartment.id='%s'", var.compartment_id)
}

resource "oci_identity_dynamic_group" "wlsc_instance_principal_group" {
  count = var.create_policies ? 1 : 0
  compartment_id = var.tenancy_id
  description    = "dynamic group to allow access to resources"
  matching_rule  = "ALL { ${local.compartment} }"
  name           = "${var.label_prefix}-wlsc-principal-group"

  lifecycle {
    ignore_changes = [matching_rule]
  }
}
