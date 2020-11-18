# Copyright 2020, Oracle Corporation and/or affiliates.  All rights reserved.

locals {
  ss_policy_statement1 = var.create_policies ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to use secret-family in tenancy" : ""
  ss_policy_statement2 = var.create_policies ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to use keys in tenancy" : ""
  ss_policy_statement3 = var.create_policies ? "Allow service VaultSecret to use keys in tenancy" : ""

  sv_policy_statement1 = var.create_policies ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage volume-family in tenancy" : ""
  sv_policy_statement2 = var.create_policies ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage instance-family in tenancy" : ""
  sv_policy_statement3 = (var.create_policies && var.ocidb_network_compartment_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage virtual-network-family in compartment id ${var.ocidb_network_compartment_id}" : ""

  lb_policy_statement  = var.create_policies ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage load-balancers in compartment id ${var.network_compartment_id}" : ""
  atp_policy_statement = (var.atp_db.is_atp && var.create_policies) ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage autonomous-transaction-processing-family in tenancy" : ""
  db_policy_statement  = (var.create_policies && var.ocidb_existing_vcn_add_seclist && var.ocidb_network_compartment_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage virtual-network-family in compartment id ${var.ocidb_network_compartment_id}" : ""
}

resource "oci_identity_policy" "wlsc_secret-service-policy" {
  count = var.create_policies ? 1 : 0

  compartment_id = var.tenancy_id
  description    = "policy to allow access to secrets in vault"
  name           = "${var.label_prefix}-secrets-policy"
  statements     = [local.ss_policy_statement1, local.ss_policy_statement2, local.ss_policy_statement3]
}

resource "oci_identity_policy" "wlsc_service-policy" {
  count = var.create_policies ? 1 : 0

  compartment_id = var.tenancy_id
  description    = "policy to access compute instances and block storage volumes"
  name           = "${var.label_prefix}-service-policy"
  statements     = compact([local.sv_policy_statement1, local.sv_policy_statement2, local.sv_policy_statement3])
}

resource "oci_identity_policy" "wlsc_atp-policy" {
  count = var.atp_db.is_atp && var.create_policies ? 1 : 0

  compartment_id = var.tenancy_id
  description    = "policy to allow WebLogic Cloud service to manage ATP DB in compartment"
  name           = "${var.label_prefix}-atp-policy"
  statements     = [local.atp_policy_statement]
}

resource "oci_identity_policy" "wlsc_db-network-policy" {
  count = (var.create_policies && var.ocidb_existing_vcn_add_seclist && var.ocidb_network_compartment_id != "") ? 1 : 0

  compartment_id = var.tenancy_id
  description    = "policy to allow WebLogic Cloud service to manage virtual-network-family in DB compartment"
  name           = "${var.label_prefix}-db-network-policy"
  statements     = [local.db_policy_statement]
}

resource "oci_identity_policy" "wlsc_lb-policy" {
  count = var.create_policies  && var.add_loadbalancer? 1 : 0

  compartment_id = var.tenancy_id
  description    = "policy to allow WebLogic Cloud service to manage load balancer in WLSC network compartment"
  name           = "${var.label_prefix}-lb-policy"
  statements     = [local.lb_policy_statement]
}