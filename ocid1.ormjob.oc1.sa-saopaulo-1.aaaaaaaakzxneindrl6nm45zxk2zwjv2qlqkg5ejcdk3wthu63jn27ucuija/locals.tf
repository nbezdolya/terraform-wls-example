
/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

locals {
  compartment_ocid = var.compartment_ocid
  is_atp_db        = trimspace(var.atp_db_id) == "" ? false : true
  home_region     = lookup(data.oci_identity_regions.home-region.regions[0], "name")

  // Deploy sample-app only if the edition is not SE
  deploy_sample_app = var.deploy_sample_app && var.wls_edition != "SE" ? "true" : "false"

  // Default DB user for ATP DB is admin
  db_user     = local.is_atp_db ? "ADMIN" : var.oci_db_user
  db_password = local.is_atp_db ? var.atp_db_password_ocid : var.oci_db_password_ocid
  is_oci_db   = trimspace(var.ocidb_dbsystem_id) == "" ? false : true
  ocidb_network_compartment_id = local.is_oci_db && var.ocidb_network_compartment_id == "" ? var.ocidb_compartment_id : var.ocidb_network_compartment_id

  // Criteria for VCN peering:
  // 1. Only when both WLS VCN name is provided (wls_vcn_name) and DB VCN ID is provided (ocidb_existing_vcn_id)
  // 2. or when both WLS VCN ID is provided (wls_existing_vcn_id) and DB VCN ID is provided (ocidb_existing_vcn_id) and they are different IDs
  // 3. and when feature flag (use_local_vcn_peering) is set to true
  is_vcn_peering = var.wls_vcn_name != "" && var.ocidb_existing_vcn_id != "" || var.wls_existing_vcn_id != "" && var.ocidb_existing_vcn_id != "" && var.wls_existing_vcn_id != var.ocidb_existing_vcn_id && var.use_local_vcn_peering ? "true" : "false"

  assign_weblogic_public_ip = var.assign_weblogic_public_ip == "true" && var.subnet_type == "Use Public Subnet" ? "true" : "false"

  bastion_subnet_cidr     = var.bastion_subnet_cidr == "" && var.wls_vcn_name != "" && local.assign_weblogic_public_ip == "false" ? local.is_vcn_peering ? "11.0.6.0/24" : "10.0.6.0/24" : var.bastion_subnet_cidr
  wls_subnet_cidr         = var.wls_subnet_cidr == "" && var.wls_vcn_name != "" ? local.is_vcn_peering ? "11.0.3.0/24" : "10.0.3.0/24" : var.wls_subnet_cidr
  lb_subnet_1_subnet_cidr = var.lb_subnet_1_cidr == "" && var.wls_vcn_name != "" ? local.is_vcn_peering ? "11.0.4.0/24" : "10.0.4.0/24" : var.lb_subnet_1_cidr
  lb_subnet_2_subnet_cidr = var.lb_subnet_2_cidr == "" && var.wls_vcn_name != "" ? local.is_vcn_peering ? "11.0.5.0/24" : "10.0.5.0/24" : var.lb_subnet_2_cidr
  wls_dns_subnet_cidr     = var.wls_dns_subnet_cidr == "" && var.wls_vcn_name != "" ? local.is_vcn_peering ? "11.0.7.0/24" : "10.0.7.0/24" : var.wls_dns_subnet_cidr
  tf_version_file         = "version.txt"
  use_existing_subnets    = var.wls_subnet_id == "" && var.lb_subnet_1_id == "" && var.lb_subnet_2_id == "" ? false : true

  # Remove all characters from the service_name that dont satisfy the criteria:
  # must start with letter, must only contain letters and numbers and length between 1,8
  # See https://github.com/google/re2/wiki/Syntax - regex syntax supported by replace()
  service_name_prefix = replace(var.service_name, "/[^a-zA-Z0-9]/", "")

  requires_JRF           = local.is_oci_db || local.is_atp_db ? true : false
  prov_type              = local.requires_JRF ? local.is_atp_db ? "(JRF with ATP DB)" : "(JRF with OCI DB)" : "(Non JRF)"
  use_regional_subnet    = (var.use_regional_subnet && var.subnet_span == "Regional Subnet") ? true : false
  network_compartment_id = var.network_compartment_id == "" ? var.compartment_ocid : var.network_compartment_id
  ocidb_compartment_id   = var.ocidb_compartment_id == "" ? local.network_compartment_id : var.ocidb_compartment_id
  dns_instance_shape     = var.dns_instance_shape == "" ? var.instance_shape : var.dns_instance_shape

  #Availability Domains
  ad_names=data.template_file.ad_names.*.rendered
  bastion_availability_domain = var.bastion_subnet_id!=""? (local.use_regional_subnet ? local.ad_names[0] : data.oci_core_subnet.bastion_subnet[0].availability_domain):(local.use_regional_subnet ? local.ad_names[0]:var.wls_availability_domain_name)
  #for existing wls subnet, get AD from the subnet
  wls_availability_domain = local.use_regional_subnet ? local.ad_names[0]: (var.wls_subnet_id==""?var.wls_availability_domain_name:data.oci_core_subnet.wls_subnet[0].availability_domain)
  lb_availability_domain_name1=var.lb_subnet_1_id!=""? (local.use_regional_subnet ? "" : data.oci_core_subnet.lb_subnet_1_id[0].availability_domain): var.lb_subnet_1_availability_domain_name
  lb_availability_domain_name2=var.lb_subnet_2_id!=""? (local.use_regional_subnet ? "" : data.oci_core_subnet.lb_subnet_2_id[0].availability_domain): var.lb_subnet_2_availability_domain_name

  #map of Tag key and value
  #special chars string denotes empty values for tags for validation purposes
  #otherwise zipmap function below fails first for empty strings before validators executed
  use_defined_tags = var.defined_tag == "~!@#$%^&*()" && var.defined_tag_value == "~!@#$%^&*()" ? false : true

  use_freeform_tags = var.free_form_tag == "~!@#$%^&*()" && var.free_form_tag_value == "~!@#$%^&*()" ? false : true

  #ignore defaults of special chars if tags are not provided
  defined_tag         = false == local.use_defined_tags ? "" : var.defined_tag
  defined_tag_value   = false == local.use_defined_tags ? "" : var.defined_tag_value
  free_form_tag       = false == local.use_freeform_tags ? "" : var.free_form_tag
  free_form_tag_value = false == local.use_freeform_tags ? "" : var.free_form_tag_value

  defined_tags = zipmap(
    compact([trimspace(local.defined_tag)]),
    compact([trimspace(local.defined_tag_value)]),
  )
  freeform_tags = zipmap(
    compact([trimspace(local.free_form_tag)]),
    compact([trimspace(local.free_form_tag_value)]),
  )

  atp_db = {
    is_atp = local.is_atp_db
    compartment_id = var.atp_db_compartment_id
  }

  lbCount = var.add_load_balancer?1:0

  lb_subnet_1_name= var.is_lb_private?"lbprisbt1":"lbpubsbt1"
  lb_subnet_2_name= var.is_lb_private?"lbprisbt2":"lbpubsbt2"
}
