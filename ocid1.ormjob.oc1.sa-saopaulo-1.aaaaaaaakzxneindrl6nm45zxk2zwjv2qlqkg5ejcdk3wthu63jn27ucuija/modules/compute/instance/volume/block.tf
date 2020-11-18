/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

resource "oci_core_volume" "wls-block-volume" {
  count               = var.numVMInstances
  availability_domain = var.use_regional_subnet?var.ad_names[count.index % length(var.ad_names)]:var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${var.compute_name_prefix}-${var.volume_name}-block-${count.index}"
  size_in_gbs         = var.volume_size
  defined_tags        = var.defined_tags
  freeform_tags       = var.freeform_tags
}

