/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

locals {
  dns_label = "wlsdnssubnet"

  //wls_vcn_cidr = "${var.wls_vcn_cidr == "" ? lookup(data.oci_core_vcns.wls_vcn.virtual_networks[0], "cidr_block") : var.wls_vcn_cidr}"
}

data "oci_core_vcns" "wls_vcn" {
  count = var.is_vcn_peering?1:0

  #Required
  compartment_id = var.network_compartment_id

  #Optional
  filter {
    name   = "id"
    values = [var.wls_vcn_id]
  }
}

data "oci_database_db_systems" "ocidb_db_systems" {
  count = var.is_vcn_peering?1:0

  #Required
  compartment_id = var.ocidb_compartment_id

  filter {
    name   = "id"
    values = [var.ocidb_dbsystem_id]
  }
}

data "oci_database_database" "ocidb_database" {
  count = var.is_vcn_peering?1:0

  #Required
  database_id = var.ocidb_database_id
}

data "oci_core_vcns" "ocidb_vcn" {
  count = var.is_vcn_peering?1:0

  #Required
  compartment_id = var.ocidb_network_compartment_id

  #Optional
  filter {
    name   = "id"
    values = [var.ocidb_existing_vcn_id]
  }
}

data "oci_core_internet_gateways" "ocidb_vcn_internet_gateway" {
  count = var.is_vcn_peering ?1:0

  #Required
  compartment_id = var.ocidb_network_compartment_id
  vcn_id         = var.ocidb_existing_vcn_id
}

data "oci_core_subnet" "ocidb_subnet" {
  count = var.is_vcn_peering?1:0

  #Required
  subnet_id = lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0],"subnet_id")
}

data "oci_core_internet_gateways" "wls_vcn_internet_gateway" {
  count = var.is_vcn_peering?1:0

  #Required
  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
}

data "oci_core_service_gateways" "wls_vcn_service_gateway" {
  count = !var.assign_public_ip && var.is_vcn_peering?1:0

  #Required
  compartment_id = var.network_compartment_id
  vcn_id         = var.wls_vcn_id
}

data "oci_identity_availability_domains" "ADs" {
  count          = var.is_vcn_peering?1:0
  compartment_id = var.tenancy_ocid
}


data "oci_core_services" "tf_services" {
  filter {
    name   = "cidr_block"
    values = ["all-.*-services-in-oracle-services-network"]
    regex  = true
  }
}