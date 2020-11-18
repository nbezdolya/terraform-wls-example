/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

module "middleware-volume" {
  source = "./volume"

  availability_domain   = var.availability_domain
  compute_name_prefix   = var.compute_name_prefix
  numVMInstances        = var.numVMInstances
  use_regional_subnet   = var.use_regional_subnet
  ad_names              = local.ad_names
  compartment_ocid      = var.compartment_ocid
  defined_tags          = var.defined_tags
  freeform_tags         = var.freeform_tags
  volume_name           = "mw"
}

module "data-volume" {
  source = "./volume"
  availability_domain   = var.availability_domain
  compute_name_prefix   = var.compute_name_prefix
  numVMInstances        = var.numVMInstances
  use_regional_subnet   = var.use_regional_subnet
  ad_names              = local.ad_names
  compartment_ocid      = var.compartment_ocid
  defined_tags          = var.defined_tags
  freeform_tags         = var.freeform_tags
  volume_name           = "data"
}