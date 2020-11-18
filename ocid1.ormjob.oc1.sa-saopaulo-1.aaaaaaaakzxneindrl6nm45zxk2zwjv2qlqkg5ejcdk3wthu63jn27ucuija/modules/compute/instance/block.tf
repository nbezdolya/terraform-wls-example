/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */

resource "oci_core_volume_attachment" "wls-mw-block-volume-attach" {
  count           = !local.is_apply_JRF? var.numVMInstances * var.num_volumes: 0
  display_name    = "${var.compute_name_prefix}-block-volume-attach-${count.index}"
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.wls_no_jrf_instance.*.id[count.index / var.num_volumes]
  volume_id       = module.middleware-volume.DataVolumeOcids[count.index / var.num_volumes]
}

resource "oci_core_volume_attachment" "wls-data-block-volume-attach" {
  count           = !local.is_apply_JRF? var.numVMInstances * var.num_volumes: 0
  display_name    = "${var.compute_name_prefix}-block-volume-attach-${count.index}"
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.wls_no_jrf_instance.*.id[count.index / var.num_volumes]
  volume_id       = module.data-volume.DataVolumeOcids[count.index/ var.num_volumes]
}

resource "oci_core_volume_attachment" "wls-mw-block-volume-attach-atp" {
  count           = local.is_atp_db? var.numVMInstances * var.num_volumes : 0
  display_name    = "${var.compute_name_prefix}-block-volume-attach-${count.index}"
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.wls-atp-instance.*.id[count.index]
  volume_id       = module.middleware-volume.DataVolumeOcids[count.index/ var.num_volumes]
}

resource "oci_core_volume_attachment" "wls-data-block-volume-attach-atp" {
  count           = local.is_atp_db? var.numVMInstances * var.num_volumes : 0
  display_name    = "${var.compute_name_prefix}-block-volume-attach-${count.index}"
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.wls-atp-instance.*.id[count.index / var.num_volumes]
  volume_id       = module.data-volume.DataVolumeOcids[count.index/ var.num_volumes]
}

resource "oci_core_volume_attachment" "wls-mw-block-volume-attach-ocidb" {
  count           =  local.is_oci_db && !var.is_vcn_peered? var.numVMInstances * var.num_volumes: 0
  display_name    = "${var.compute_name_prefix}-block-volume-attach-${count.index}"
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.wls_ocidb_instance.*.id[count.index / var.num_volumes]
  volume_id       = module.middleware-volume.DataVolumeOcids[count.index / var.num_volumes]
}

resource "oci_core_volume_attachment" "wls-data-block-volume-attach-ocidb" {
  count           = local.is_oci_db && !var.is_vcn_peered? var.numVMInstances * var.num_volumes: 0
  display_name    = "${var.compute_name_prefix}-block-volume-attach-${count.index}"
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.wls_ocidb_instance.*.id[count.index / var.num_volumes]
  volume_id       = module.data-volume.DataVolumeOcids[count.index/ var.num_volumes]
}

resource "oci_core_volume_attachment" "wls-mw-block-volume-attach-ocidb-peeredvcn" {
  count           =  local.is_oci_db && var.is_vcn_peered? var.numVMInstances * var.num_volumes: 0
  display_name    = "${var.compute_name_prefix}-block-volume-attach-${count.index}"
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.wls_ocidb_peered_vcn_instance.*.id[count.index / var.num_volumes]
  volume_id       = module.middleware-volume.DataVolumeOcids[count.index / var.num_volumes]
}

resource "oci_core_volume_attachment" "wls-data-block-volume-attach-ocidb-peeredvcn" {
  count           = local.is_oci_db && var.is_vcn_peered? var.numVMInstances * var.num_volumes: 0
  display_name    = "${var.compute_name_prefix}-block-volume-attach-${count.index}"
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.wls_ocidb_peered_vcn_instance.*.id[count.index / var.num_volumes]
  volume_id       = module.data-volume.DataVolumeOcids[count.index/ var.num_volumes]
}
