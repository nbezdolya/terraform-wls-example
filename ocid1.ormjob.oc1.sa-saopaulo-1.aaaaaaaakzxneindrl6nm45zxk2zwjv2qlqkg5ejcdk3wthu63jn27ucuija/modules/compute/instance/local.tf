/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

locals {
  host_label = "${var.compute_name_prefix}-${var.vnic_prefix}"
  ad_names=data.template_file.ad_names.*.rendered

  is_oci_db         = trimspace(var.ocidb_dbsystem_id)!= ""?true: false
  is_atp_db         = trimspace(var.atp_db_id)!=""? true: false
  is_apply_JRF      = local.is_oci_db || local.is_atp_db? true: false
  num_fault_domains = length(data.oci_identity_fault_domains.wls_fault_domains.fault_domains)
  wls_subnet_cidr   = (var.wls_subnet_id == "") ? var.wls_subnet_cidr : data.oci_core_subnet.wls_subnet[0].cidr_block

  # Default to "ASM" if storage_management is not found. This attribute is not there for baremetal and Exadata.
  db_options = local.is_oci_db ? lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "db_system_options", []) : []
  db_storage_management = local.is_oci_db && length(local.db_options) > 0 ? lookup(local.db_options[0], "storage_management", "ASM") : "ASM"
}