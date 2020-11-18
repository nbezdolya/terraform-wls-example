/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */

locals {

  validators_msg_map = { #Dummy map to trigger an error in case we detect a validation error.
  }

  invalid_service_name_prefix = (length(var.service_name_prefix)>8) || (length(var.service_name_prefix)<1) || (length(replace(substr(var.service_name_prefix, 0, 1), "/[0-9]/", ""))==0) || length(var.service_name_prefix) != length(var.original_service_name)
  invalid_vm_count            = (var.numVMInstances <1) || (var.numVMInstances > 8)

  invalid_11g_SE_vm_count     = (var.wls_version == "11.1.1.7") && (var.wls_edition=="SE") && (var.numVMInstances <1 || var.numVMInstances >4)

  missing_lb_availability_domains = !var.use_regional_subnet && var.add_load_balancer && (var.lb_availability_domain_name1 == "" || var.lb_availability_domain_name2 == "")

  invalid_lb_availability_domain_indexes = !var.use_regional_subnet && var.add_load_balancer && var.lb_availability_domain_name1 != "" && (var.lb_availability_domain_name1 == var.lb_availability_domain_name2)

  invalid_wls_edition               = !contains(list("SE","EE","SUITE"),var.wls_edition)
  invalid_wls_version               = ! contains(list("12.2.1.3","12.2.1.4","11.1.1.7"),var.wls_version)
  is11gVersion                      = var.wls_version == "11.1.1.7"
  isNonJRF                          = !var.is_atp_db && !var.is_oci_db
  invalid_atp_db_not_allowed        = local.is11gVersion && (var.is_atp_db|| local.isNonJRF)
  invalid_wls_console_port          = (var.wls_console_port <=0)
  invalid_wls_console_ssl_port      = (var.wls_console_ssl_port <=0)
  invalid_wls_extern_admin_port     = (var.wls_extern_admin_port <=0)
  invalid_wls_extern_ssl_admin_port = (var.wls_extern_ssl_admin_port <=0)
  invalid_wls_nm_port               = (var.wls_nm_port <=0)
  invalid_wls_ms_port               = (var.wls_ms_port <=0)
  wls_port_list                     = list("9071", "9072", "9073", "9074")
  reserved_wls_ports                = contains(local.wls_port_list, var.wls_ms_port) || contains(local.wls_port_list, var.wls_ms_ssl_port) || contains(local.wls_port_list, var.wls_extern_admin_port) || contains(local.wls_port_list, var.wls_extern_ssl_admin_port)
  invalid_wls_cluster_mc_port       = (var.wls_cluster_mc_port<=0)
  has_wls_subnet_cidr               = var.wls_subnet_cidr!=""
  has_mgmt_subnet_cidr              = var.is_bastion_instance_required ? (var.bastion_subnet_cidr!="" || var.existing_bastion_instance_id != "") : true
  has_lb_subnet_1_cidr              = var.lb_subnet_1_cidr!=""
  has_lb_subnet_2_cidr              = var.lb_subnet_2_cidr!=""
  missing_wls_subnet_cidr           = var.existing_vcn_id!="" && var.wls_subnet_id=="" ?!local.has_wls_subnet_cidr: false
  missing_lb_subnet_1_cidr          = (var.add_load_balancer) && var.existing_vcn_id!="" && var.lb_subnet_1_id=="" ?!local.has_lb_subnet_1_cidr: false

  //missing_lb_subnet_2_cidr          = "${var.existing_vcn_id!="" && var.lb_subnet_2_id=="" && var.use_regional_subnet == "false" && local.is_single_ad_region == "false"?local.has_lb_subnet_2_cidr: 0}"
  //missing_mgmt_backend_subnet_cidr = ((var.existing_vcn_id!="") && (var.assign_public_ip=="false") && var.bastion_subnet_id=="")?local.has_mgmt_subnet_cidr : false
  missing_mgmt_backend_subnet_cidr = (var.existing_vcn_id!="" && var.assign_public_ip=="false" && var.bastion_subnet_id=="" && var.is_bastion_instance_required && var.existing_bastion_instance_id =="") ? !local.has_mgmt_subnet_cidr : false

  duplicate_wls_subnet_cidr_with_lb1_cidr  = (var.add_load_balancer) && (local.has_lb_subnet_1_cidr) && (local.has_wls_subnet_cidr) && (var.wls_subnet_cidr==var.lb_subnet_1_cidr)
  duplicate_wls_subnet_cidr_with_lb2_cidr  = (var.add_load_balancer) && ( var.use_regional_subnet == false ) && (local.has_lb_subnet_2_cidr) && (local.has_wls_subnet_cidr) && (var.wls_subnet_cidr==var.lb_subnet_2_cidr)
  duplicate_wls_subnet_cidr_with_private_subnet_cidr = ((var.existing_vcn_id=="") && (var.assign_public_ip=="false") && var.bastion_subnet_id=="") && (local.has_mgmt_subnet_cidr) && (local.has_wls_subnet_cidr) && (var.wls_subnet_cidr == var.bastion_subnet_cidr)

  check_duplicate_wls_subnet_cidr = var.wls_subnet_cidr!=""  && (local.duplicate_wls_subnet_cidr_with_lb1_cidr || local.duplicate_wls_subnet_cidr_with_lb2_cidr || local.duplicate_wls_subnet_cidr_with_private_subnet_cidr)

  #lb1 check
  duplicate_lb1_subnet_cidr_with_lb2_cidr            = (var.add_load_balancer) && (var.use_regional_subnet  == false) && (local.has_lb_subnet_1_cidr) && (local.has_lb_subnet_2_cidr) && (var.lb_subnet_1_cidr==var.lb_subnet_2_cidr)
  duplicate_lb1_subnet_cidr_with_private_subnet_cidr = ((var.assign_public_ip=="false") && var.bastion_subnet_id=="") && (local.has_mgmt_subnet_cidr) && (local.has_lb_subnet_1_cidr) && (var.lb_subnet_1_cidr == var.bastion_subnet_cidr)

  check_duplicate_lb1_subnet_cidr = local.has_lb_subnet_1_cidr && (local.duplicate_lb1_subnet_cidr_with_lb2_cidr || local.duplicate_lb1_subnet_cidr_with_private_subnet_cidr)

  #lb2 check
  duplicate_lb2_subnet_cidr_with_private_subnet_cidr = (var.add_load_balancer) && ( var.use_regional_subnet == false ) && ((var.assign_public_ip=="false") && var.bastion_subnet_id=="") && (local.has_mgmt_subnet_cidr) && (local.has_lb_subnet_2_cidr) && (var.lb_subnet_2_cidr == var.bastion_subnet_cidr)
  check_duplicate_lb2_subnet_cidr                    = local.has_lb_subnet_2_cidr && local.duplicate_lb2_subnet_cidr_with_private_subnet_cidr

  #multiple infra db
  invalid_multiple_infra_dbs      = (var.is_oci_db && var.is_atp_db)
  missing_vcn                     = var.existing_vcn_id=="" && var.vcn_name==""
  has_existing_vcn                = var.existing_vcn_id!=""
  has_vcn_name                    = var.vcn_name!=""
  is_vcn_peering                  = ((var.vcn_name !="" && var.ocidb_existing_vcn_id != "") || (var.existing_vcn_id != "" && var.ocidb_existing_vcn_id != "" && var.existing_vcn_id != var.ocidb_existing_vcn_id))
  both_vcn_param_non_ocidb        = !var.is_oci_db? (local.has_existing_vcn && local.has_vcn_name) : false
  has_wls_subnet_id               = var.wls_subnet_id!=""
  has_lb_backend_subnet_id        = var.lb_subnet_2_id!=""
  has_lb_frontend_subnet_id       = var.lb_subnet_1_id!=""
  missing_bastion_subnet_id       = (var.is_bastion_instance_required && var.existing_bastion_instance_id != "" && var.bastion_subnet_id=="")
  has_mgmt_subnet_id              = var.is_bastion_instance_required ? var.bastion_subnet_id!=""  : true

  missing_vcn_id                = (var.existing_vcn_id=="" && (local.has_wls_subnet_id || local.has_lb_backend_subnet_id || local.has_lb_frontend_subnet_id))
  missing_private_subnet_vcn_id = (var.is_bastion_instance_required &&( var.bastion_subnet_id!="" || var.existing_bastion_instance_id != "")  && var.existing_vcn_id=="")


  #existing subnets
  # If load balancer selected, check LB and WLS have existing subnet IDs specified else, if load balancer is not selected, check if WLS is using existing subnet id
  has_all_existing_subnets = (var.add_load_balancer && local.has_wls_subnet_id && local.has_lb_backend_subnet_id && local.has_lb_frontend_subnet_id) || (!var.add_load_balancer && local.has_wls_subnet_id)

  has_all_new_subnets      = (var.add_load_balancer && !local.has_wls_subnet_id && !local.has_lb_backend_subnet_id && !local.has_lb_frontend_subnet_id) || (!var.add_load_balancer && !local.has_wls_subnet_id)
  is_subnet_condition      = (local.has_all_existing_subnets || local.has_all_new_subnets )
  missing_existing_subnets = (var.assign_public_ip=="true")?local.is_subnet_condition:false

  #existing private AD subnet
  has_all_existing_private_subnets = (var.add_load_balancer && local.has_wls_subnet_id && local.has_lb_backend_subnet_id && local.has_lb_frontend_subnet_id && local.has_mgmt_subnet_id) || ((!var.add_load_balancer && local.has_wls_subnet_id && local.has_mgmt_subnet_id))
  has_all_new_private_subnets      = (var.add_load_balancer && local.has_wls_subnet_cidr && local.has_lb_subnet_1_cidr && local.has_lb_subnet_2_cidr && local.has_mgmt_subnet_cidr) || (!var.add_load_balancer && local.has_wls_subnet_cidr && local.has_mgmt_subnet_cidr)
  is_private_subnet_condition      = (local.has_all_existing_private_subnets  || local.has_all_new_private_subnets)
  missing_existing_private_subnets = !local.is_private_subnet_condition

  #existing regional validation
  has_all_existing_regional_subnets = (var.add_load_balancer && local.has_wls_subnet_id && local.has_lb_frontend_subnet_id) || (!var.add_load_balancer && local.has_wls_subnet_id)
  has_all_new_regional_subnets      = (var.add_load_balancer && local.has_wls_subnet_cidr && local.has_lb_subnet_1_cidr) || (!var.add_load_balancer && local.has_wls_subnet_cidr)
  is_regional_subnet_condition      = (local.has_all_existing_regional_subnets || local.has_all_new_regional_subnets )
  has_existing_regional_subnets     = local.is_regional_subnet_condition

  #existing private regional validation
  has_all_existing_private_regional_subnets = (var.add_load_balancer && local.has_wls_subnet_id  && local.has_lb_frontend_subnet_id && local.has_mgmt_subnet_id) || (!var.add_load_balancer && local.has_wls_subnet_id && local.has_mgmt_subnet_id)
  has_all_new_private_regional_subnets      = (var.add_load_balancer && local.has_wls_subnet_cidr && local.has_lb_subnet_1_cidr && local.has_mgmt_subnet_cidr) || (!var.add_load_balancer && local.has_wls_subnet_cidr && local.has_mgmt_subnet_cidr)
  is_private_regional_subnet_condition      = (local.has_all_existing_private_regional_subnets || local.has_all_new_private_regional_subnets )
  has_existing_private_regional_subnets = local.is_private_regional_subnet_condition

  #disable bastion host provisioning in privat subnet
  is_bastion_turned_off                = !var.is_bastion_instance_required
  is_existing_bastion_condition = (var.assign_public_ip=="false" && var.is_bastion_instance_required && var.existing_bastion_instance_id != "")
  bastion_ssh_key_file = var.bastion_ssh_private_key == "" ? "missing.txt" : var.bastion_ssh_private_key
  invalid_bastion_private_key = (local.is_existing_bastion_condition && (var.bastion_ssh_private_key == ""  || !fileexists(local.bastion_ssh_key_file) ))

  missing_wls_dns_subnet_info = local.is_vcn_peering && (var.wls_dns_subnet_cidr=="")

  peering_not_enabled = local.is_vcn_peering && var.use_local_vcn_peering == false

  # wls admin user validation
  invalid_wls_admin_user = replace(var.wls_admin_user,"/^[a-zA-Z][a-zA-Z0-9]{7,127}/", "0")

  #tag validations

  #special chars string denotes empty values for tags for validation purposes
  #otherwise zipmap function main.tf fails first for empty strings before validators executed
  defined_tag = var.defined_tag=="~!@#$%^&*()"?"":var.defined_tag
  defined_tag_value = var.defined_tag_value=="~!@#$%^&*()"?"":var.defined_tag_value
  freeform_tag = var.freeform_tag=="~!@#$%^&*()"?"":var.freeform_tag
  freeform_tag_value = var.freeform_tag_value=="~!@#$%^&*()"?"":var.freeform_tag_value

  invalid_defined_tag=(local.defined_tag=="")||(length(split(".",local.defined_tag))==2)

  check_defined_tag=var.defined_tag==""?false:local.invalid_defined_tag

  has_defined_tag_key                 = local.defined_tag==""
  has_defined_tag_value               = local.defined_tag_value==""

  has_freeform_tag_key               = local.freeform_tag==""
  has_freeform_tag_value             = local.freeform_tag_value==""

  missing_defined_tag_key = local.has_defined_tag_value && !local.has_defined_tag_key
  missing_defined_tag_value = !local.has_defined_tag_value && local.has_defined_tag_key

  missing_freeform_tag_key = local.has_freeform_tag_value && !local.has_freeform_tag_key
  missing_freeform_tag_value = !local.has_freeform_tag_value && local.has_freeform_tag_key

  #tag length validation
  invalid_length_defined_tag =length(local.defined_tag)>100
  invalid_length_defined_tag_value =length(local.defined_tag_value)>256

  invalid_length_freeform_tag =length(local.freeform_tag)>100
  invalid_length_freeform_tag_value =length(local.freeform_tag_value)>256

  invalid_lb_type=var.is_lb_private=="true" && var.assign_public_ip=="true"

  #Validate wls AD value only if AD subnets are used and it is new subnet use case
  #for existing subnets we derive the AD from the subnet using datasource
  invalid_wls_availability_domain = (!var.use_regional_subnet && var.wls_availability_domain_name=="" && var.wls_subnet_id=="")

  # Validations
  peering_reqd_but_disabled_msg = "WLSC-ERROR: VCN peering is required as one of WLS VCN name [${var.vcn_name}] or WLS VCN ID [${var.existing_vcn_id}] and DB System VCN ID [${var.ocidb_existing_vcn_id}] are different VCNs but the VCN peering feature is disabled [${var.use_local_vcn_peering}]. Please enable it by setting [use_local_vcn_peering] to [true]."
  validate_peering_reqd_but_disabled = local.peering_not_enabled ? local.validators_msg_map[local.peering_reqd_but_disabled_msg] : null

  service_name_prefix_msg = "WLSC-ERROR: The [service_name] min length is 1 and max length is 8 characters. It can only contain letters or numbers and must begin with a letter. Invalid service name: [${var.original_service_name}]"
  validate_service_name_prefix = local.invalid_service_name_prefix ? local.validators_msg_map[local.service_name_prefix_msg] : null

  missing_wls_dns_subnet_info_msg = "WLSC-ERROR: The value for [wls_dns_subnet_cidr] is required when using VCN peering [different WLS VCN and DB System VCN]."
  validate_missing_wls_dns_subnet_info = local.missing_wls_dns_subnet_info ? local.validators_msg_map[local.missing_wls_dns_subnet_info_msg] : null

  both_vcn_param_non_ocidb_msg = "WLSC-ERROR: Both existing_vcn_id and wls_vcn_name cannot be provided if not provisioning with OCI DB."
  validate_both_vcn_param_non_ocidb = local.both_vcn_param_non_ocidb ? local.validators_msg_map[local.both_vcn_param_non_ocidb_msg] : null

  invalid_db_msg = "WLSC-ERROR: Weblogic 11g version is not supported with ATP DB and Non-JRF provisioning."
  invalid_db_not_allowed = local.invalid_atp_db_not_allowed ? local.validators_msg_map[local.invalid_db_msg] : null

  vcn_params_msg = "WLSC-ERROR: Atleast existing_vcn_id or vcn_name must be provided. Both can only be provided when provisioning with OCI DB in peered VCNs."
  validate_vcn_params = local.missing_vcn ? local.validators_msg_map[local.vcn_params_msg] : null

  invalid_log_level     = ! contains(list("DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"), var.log_level)
  invalid_log_level_msg = "WLSC-ERROR: The value for log_level=[${var.log_level}] is not valid. The permissible values are [DEBUG, INFO, WARNING, ERROR, CRITICAL]"
  validate_log_level    = local.invalid_log_level ? local.validators_msg_map[local.invalid_log_level_msg] : null

  numVMInstances_msg = "WLSC-ERROR: The value for wls_node_count=[${var.numVMInstances}] is not valid. The permissible values are [1-8]."
  validate_numVMInstances = local.invalid_vm_count ? local.validators_msg_map[local.numVMInstances_msg] : null

  SE_11g_numVMInstances_msg = "WLSC-ERROR: The value for wls_node_count=[${var.numVMInstances}] is not valid for Weblogic 11g Standard Edition. The permissible values are [1-4]."
  validate_11g_SE_numVMInstances = local.invalid_11g_SE_vm_count ? local.validators_msg_map[local.SE_11g_numVMInstances_msg] : null

  invalid_wls_availability_domain_msg="WLSC-ERROR: The value for wls_availability_domain is required for AD specific subnets."
  validate_wls_availability_domain = local.invalid_wls_availability_domain ? local.validators_msg_map[local.invalid_wls_availability_domain_msg] : null

  lb_availability_domain_indexes_msg = "WLSC-ERROR: The value for lb_subnet_1_availability_domain_name=[${var.lb_availability_domain_name1}] and lb_subnet_2_availability_domain_name=[${var.lb_availability_domain_name2}] cannot be same."
  validate_lb_availability_domain_indexes = local.invalid_lb_availability_domain_indexes ? local.validators_msg_map[local.lb_availability_domain_indexes_msg] : null

  lb_availability_domains_required_msg = "WLSC-ERROR: The values for lb_subnet_1_availability_domain_name and lb_subnet_2_availability_domain_name are required for AD specific subnets."
  missing_lb_availability_domain_names = local.missing_lb_availability_domains ? local.validators_msg_map[local.lb_availability_domains_required_msg] : null

  wls_edition_msg = "WLSC-ERROR: The value for wls_edition=[${var.wls_edition}] is not valid. The permissible values are [ EE, SUITE ]."
  validate_wls_edition = local.invalid_wls_edition ? local.validators_msg_map[local.wls_edition_msg] : null

  wls_version_msg = "WLSC-ERROR: The value for wls_version=[${var.wls_version}] is not valid. The permissible values are [ 11.1.1.7, 12.2.1.3, 12.2.1.4 ]."
  validate_invalid_wls_version = local.invalid_wls_version ? local.validators_msg_map[local.wls_version_msg] : null

  wls_console_port_msg = "WLSC-ERROR: The value for wls_console_port=[${var.wls_console_port}] is not valid. The value has to be greater than 0."
  validate_wls_console_port = local.invalid_wls_console_port ? local.validators_msg_map[local.wls_console_port_msg] : null

  wls_console_ssl_port_msg = "WLSC-ERROR: The value for wls_console_ssl_port=[${var.wls_console_ssl_port}] is not valid. The value has to be greater than 0."
  validate_wls_console_ssl_port = local.invalid_wls_console_ssl_port ? local.validators_msg_map[local.wls_console_ssl_port_msg] : null

  wls_extern_admin_port_msg = "WLSC-ERROR: The value for wls_extern_admin_port=[${var.wls_extern_admin_port}] is not valid. The value has to be greater than 0."
  validate_wls_extern_admin_port = local.invalid_wls_extern_admin_port ? local.validators_msg_map[local.wls_extern_admin_port_msg] : null

  wls_extern_ssl_admin_port_msg = "WLSC-ERROR: The value for wls_extern_ssl_admin_port=[${var.wls_extern_ssl_admin_port}] is not valid. The value has to be greater than 0."
  validate_wls_extern_ssl_admin_port = local.invalid_wls_extern_ssl_admin_port ? local.validators_msg_map[local.wls_extern_ssl_admin_port_msg ] : null

  wls_nm_port_msg = "WLSC-ERROR: The value for wls_nm_port=[${var.wls_nm_port}] is not valid. The value has to be greater than 0."
  validate_wls_nm_port = local.invalid_wls_nm_port ? local.validators_msg_map[local.wls_nm_port_msg] : null

  wls_ms_port_msg = "WLSC-ERROR: The value for wls_ms_port=[${var.wls_ms_port}] is not valid. The value has to be greater than 0."
  validate_wls_ms_port = local.invalid_wls_ms_port ? local.validators_msg_map[local.wls_ms_port_msg] : null

  reserved_wls_ports_msg = "WLSC-ERROR: The port range [9071-9074] is reserved for internal use. Please choose a port that is not in this range."
  validate_wls_ports     = local.reserved_wls_ports ? local.validators_msg_map[local.reserved_wls_ports_msg] : null

  wls_cluster_mc_port_msg = "WLSC-ERROR: The value for wls_cluster_mc_port=[${var.wls_cluster_mc_port}] is not valid. The value has to be greater than 0."
  validate_wls_cluster_mc_port = local.invalid_wls_cluster_mc_port ? local.validators_msg_map[local.wls_cluster_mc_port_msg] : null

  missing_wls_subnet_cidr_msg = "WLSC-ERROR: The value for wls_subnet_cidr is required if existing virtual cloud network is used."
  validate_missing_wls_subnet_cidr = local.missing_wls_subnet_cidr ? local.validators_msg_map[local.missing_wls_subnet_cidr_msg] : null

  missing_lb_subnet_1_cidr_msg = "WLSC-ERROR: The value for lb_subnet_1_cidr is required if existing virtual cloud network is used and LB is added."
  validate_missing_lb_subnet_1_cidr = local.missing_lb_subnet_1_cidr ? local.validators_msg_map[local.missing_lb_subnet_1_cidr_msg] : null

  missing_bastion_subnet_id_msg = "WLSC-ERROR: The value for bastion subnet id is required if existing bastion instance id is used for provisioning"
  validate_missing_bastion_subnet_id = local.missing_bastion_subnet_id ? local.validators_msg_map[local.missing_bastion_subnet_id_msg] : null

  missing_mgmt_backend_subnet_cidr_msg = "WLSC-ERROR: The value for bastion_subnet_cidr is required with existing virtual cloud network and weblogic in private subnet."
  validate_missing_mgmt_backend_subnet_cidr = local.missing_mgmt_backend_subnet_cidr ? local.validators_msg_map[local.missing_mgmt_backend_subnet_cidr_msg] : null

  missing_vcn_id_msg = "WLSC-ERROR: The value for existing_vcn_id is required if existing subnets are used for provisioning."
  validate_missing_vcn_id = local.missing_vcn_id ? local.validators_msg_map[local.missing_vcn_id_msg] : null

  missing_private_subnet_vcn_id_msg = "WLSC-ERROR: The value for existing_vcn_id is required if existing bastion subnet id is used for provisioning."
  validate_missing_private_subnet_vcn_id= local.missing_private_subnet_vcn_id ? local.validators_msg_map[local.missing_private_subnet_vcn_id_msg] : null

  multiple_infra_dbs_msg = "WLSC-ERROR: Both OCI and ATP database parameters are provided. Only one infra database is required."
  validate_invalid_multiple_infra_dbs = local.invalid_multiple_infra_dbs ? local.validators_msg_map[local.multiple_infra_dbs_msg] : null

  invalid_wls_admin_user_msg = "WLSC-ERROR: WebLogic Administrator admin user provided should be alphanumeric and length should be between 8 and 128 characters. "
  validate_wls_admin_user = local.invalid_wls_admin_user !="0" ? local.validators_msg_map[local.invalid_wls_admin_user_msg] : null

  wls_subnet_cidr_msg = "WLSC-ERROR:  Weblogic subnet CIDR has to be unique value."
  duplicate_wls_subnet_cidr = local.check_duplicate_wls_subnet_cidr == true ? local.validators_msg_map[local.wls_subnet_cidr_msg] : null

  duplicate_lb1_subnet_cidr_msg = "WLSC-ERROR:  Load balancer subnet 1 CIDR has to be unique value. "
  duplicate_lb1_subnet_cidr = local.check_duplicate_lb1_subnet_cidr ? local.validators_msg_map[local.duplicate_lb1_subnet_cidr_msg] : null

  duplicate_lb2_subnet_cidr_msg = "WLSC-ERROR:  Load balancer subnet 2 CIDR has to be unique value. "
  duplicate_lb2_subnet_cidr = local.check_duplicate_lb2_subnet_cidr ? local.validators_msg_map[local.duplicate_lb2_subnet_cidr_msg] : null

  invalid_defined_tag_msg = "WLSC-ERROR: The defined tag name is not valid. The defined tag name should of the format <tagnamespace>.<tagname>."
  validate_invalid_defined_tag = local.invalid_defined_tag == false ? local.validators_msg_map[local.invalid_defined_tag_msg] : null

  missing_defined_tag_key_msg = "WLSC-ERROR:  The value for defined tag key [ defined_tag ] is required. "
  validate_missing_defined_tag_key = local.missing_defined_tag_key ? local.validators_msg_map[local.missing_defined_tag_key_msg] : null

  missing_defined_tag_value_msg = "WLSC-ERROR:  The value for defined tag key value [ defined_tag_value ] is required. "
  validate_missing_defined_tag_value = local.missing_defined_tag_value ? local.validators_msg_map[local.missing_defined_tag_value_msg] : null

  missing_freeform_tag_key_msg = "WLSC-ERROR:  The value for free-form tag key [ free_form_tag ] is required. "
  validate_missing_freeform_tag_key = local.missing_freeform_tag_key ? local.validators_msg_map[local.missing_freeform_tag_key_msg] : null

  missing_freeform_tag_value_msg = "WLSC-ERROR:  The value for free-form tag key value [ free_form_tag_value ] is required. "
  validate_missing_freeform_tag_value = local.missing_freeform_tag_value ? local.validators_msg_map[local.missing_freeform_tag_value_msg] : null

  defined_tag_length_msg = "WLSC-ERROR: The length of the defined tag is between 1-100. Invalid tag name: [${local.defined_tag}]."
  validate_defined_tag_length = local.invalid_length_defined_tag ? local.validators_msg_map[local.defined_tag_length_msg] : null

  defined_tag_value_length_msg = "WLSC-ERROR: The length of the defined tag value is between 1-256. Invalid tag value: [${local.defined_tag_value}]."
  validate_defined_tag_value_length = local.invalid_length_defined_tag_value ? local.validators_msg_map[local.defined_tag_value_length_msg] : null

  freeform_tag_length_msg = "WLSC-ERROR: The length of the free-form tag is between 1-100.  Invalid tag : [${local.freeform_tag}]."
  validate_freeform_tag_length = local.invalid_length_freeform_tag ? local.validators_msg_map[local.freeform_tag_length_msg] : null

  freeform_tag_value_length_msg = "WLSC-ERROR: The length of the free-form  tag value is between 1-256.  Invalid tag value: [${local.freeform_tag_value}]."
  validate_freeform_tag_value_length = local.invalid_length_freeform_tag_value ? local.validators_msg_map[local.freeform_tag_value_length_msg] : null

  lb_type_msg = "WLSC-ERROR: Private load balancer can only be provisioned if private subnets are used for provisioning."
  validate_lb_type = local.invalid_lb_type ? local.validators_msg_map[local.lb_type_msg] : null

  missing_existing_subnets_msg = "WLSC-ERROR: Provide all required existing subnet id if one of the existing subnets is provided[ lb_subnet_1_id, lb_subnet_2_id, wls_subnet_id ]."
  validate_missing_existing_subnets = var.use_regional_subnet? false:local.missing_existing_subnets

  missing_existing_private_subnets_msg = "WLSC-ERROR: Provide all required existing subnet ids or subnet CIDRs if one of the existing subnets is provided [ lb_subnet_1_id/cidr, lb_subnet_2_id/cidr, wls_subnet_id/cidr, bastion_subnet_id/cidr ]."
  validate_missing_existing_private_subnets = var.assign_public_ip=="false" && !var.use_regional_subnet && local.missing_existing_private_subnets ? local.validators_msg_map[local.missing_existing_private_subnets_msg] : null

  missing_existing_regional_subnets_msg = "WLSC-ERROR: Provide all required existing subnet id if one of the existing subnets is provided[ lb_subnet_1_id, wls_subnet_id ]."
  validate_missing_existing_regional_subnets = var.use_regional_subnet && !local.has_existing_regional_subnets ? local.validators_msg_map[local.missing_existing_regional_subnets_msg] : null

  missing_existing_private_regional_subnets_msg = "WLSC-ERROR: Provide all required existing subnet ids or subnet CIDRs if one of the existing subnets is provided [ lb_subnet_1_id/cidr, wls_subnet_id/cidr, bastion_subnet_id/cidr ]."
  validate_missing_existing_private_regional_subnets = var.assign_public_ip=="false" && var.use_regional_subnet && !local.has_existing_private_regional_subnets ? local.validators_msg_map[local.missing_existing_private_regional_subnets_msg] : null

  missing_existing_bastion_host_private_subnet_msg = "WLSC-ERROR: Support existing bastion host for provisioning WLS in private subnet is enabled in CLI only. Provide all required parameters [ is_bastion_instance_required, existing_bastion_instance_id, bastion_ssh_private_key ]."
  validate_missing_existing_bastion_host_private_subnet = (local.invalid_bastion_private_key) ? local.validators_msg_map[local.missing_existing_bastion_host_private_subnet_msg] : null
}
