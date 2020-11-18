/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */
resource "oci_core_instance" "wls-bastion-instance" {
  count = (var.is_bastion_instance_required && var.existing_bastion_instance_id == "") ? var.instance_count : 0

  //assumption: it is the same ad as wls
  availability_domain = var.availability_domain

  compartment_id = var.compartment_ocid
  display_name   = var.instance_name
  shape          = var.instance_shape

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags

  create_vnic_details {
    subnet_id              = var.bastion_subnet_ocid[0]
    skip_source_dest_check = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.bastion-config.rendered
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_id
  }

  timeouts {
    create = "10m"
  }
}