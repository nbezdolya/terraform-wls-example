/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */
module "compute-keygen" {
  source = "./modules/compute/keygen"
}

module "network-vcn" {
  source = "./modules/network/vcn"

  compartment_ocid = local.network_compartment_id

  // New VCN is created if vcn_name is not empty
  // Existing vcn_id is returned back without creating a new VCN if vcn_name is empty but vcn_id is provided.
  vcn_name = var.wls_vcn_name

  vcn_id               = var.wls_existing_vcn_id
  wls_vcn_cidr         = var.wls_vcn_cidr
  use_existing_subnets = local.use_existing_subnets
  service_name_prefix  = local.service_name_prefix
  defined_tags         = local.defined_tags
  freeform_tags        = local.freeform_tags
}

/* Adds new dhcp options, security list, route table */
module "network-vcn-config" {
  source = "./modules/network/vcn-config"

  compartment_id = local.network_compartment_id

  //vcn id if new is created
  vcn_id          = module.network-vcn.VcnID
  existing_vcn_id = var.wls_existing_vcn_id

  wls_ssl_admin_port = var.wls_extern_ssl_admin_port
  wls_ms_port        = var.wls_ms_extern_port
  wls_ms_ssl_port    = var.wls_ms_extern_ssl_port
  wls_admin_port     = var.wls_extern_admin_port

  wls_security_list_name       = local.assign_weblogic_public_ip == "false" ? "bastion-security-list" : "wls-security-list"
  wls_subnet_cidr              = local.wls_subnet_cidr
  lb_subnet_2_cidr             = local.lb_subnet_2_subnet_cidr
  lb_subnet_1_cidr             = local.lb_subnet_1_subnet_cidr
  add_load_balancer            = var.add_load_balancer
  wls_vcn_name                 = var.wls_vcn_name
  use_existing_subnets         = local.use_existing_subnets
  service_name_prefix          = local.service_name_prefix
  assign_backend_public_ip     = local.assign_weblogic_public_ip
  use_regional_subnets         = local.use_regional_subnet
  bastion_subnet_cidr          = local.bastion_subnet_cidr
  is_single_ad_region          = local.is_single_ad_region
  is_idcs_selected             = var.is_idcs_selected
  idcs_cloudgate_port          = var.idcs_cloudgate_port
  is_vcn_peering               = local.is_vcn_peering
  defined_tags                 = local.defined_tags
  freeform_tags                = local.freeform_tags
  is_lb_private                = var.is_lb_private
  is_bastion_instance_required = var.is_bastion_instance_required
  existing_bastion_instance_id = var.existing_bastion_instance_id
}

/* Create primary subnet for Load balancer only */
module "network-lb-subnet-1" {
  source = "./modules/network/subnet"

  compartment_ocid = local.network_compartment_id
  tenancy_ocid     = var.tenancy_ocid
  vcn_id           = module.network-vcn.VcnID
  security_list_id = module.network-vcn-config.lb_security_list_id
  dhcp_options_id  = module.network-vcn-config.dhcp_options_id
  route_table_id   = module.network-vcn-config.route_table_id[0]
  subnet_name         = "${local.service_name_prefix}-${local.lb_subnet_1_name}"
  
  #Note: limit for dns label is 15 chars
  dns_label           = format("%s-%s",substr(var.service_name, 0, 4), local.lb_subnet_1_name)
  cidr_block          = local.lb_subnet_1_subnet_cidr
  availability_domain = var.lb_subnet_1_availability_domain_name
  subnetCount         = var.add_load_balancer && var.lb_subnet_1_id == "" ? 1 : 0
  subnet_id           = var.lb_subnet_1_id
  use_regional_subnet = local.use_regional_subnet
  defined_tags        = local.defined_tags
  freeform_tags       = local.freeform_tags
  prohibit_public_ip  = var.is_lb_private
}

/* Create secondary subnet for wls and lb backend */
module "network-lb-subnet-2" {
  source = "./modules/network/subnet"

  compartment_ocid    = local.network_compartment_id
  tenancy_ocid        = var.tenancy_ocid
  vcn_id              = module.network-vcn.VcnID
  security_list_id    = module.network-vcn-config.lb_security_list_id
  dhcp_options_id     = module.network-vcn-config.dhcp_options_id
  route_table_id      = module.network-vcn-config.route_table_id[0]
  subnet_name         = "${local.service_name_prefix}-${local.lb_subnet_2_name}"

   #Note: limit for dns label is 15 chars
  dns_label           = format("%s-%s",substr(var.service_name, 0, 4), local.lb_subnet_2_name)
  cidr_block          = local.lb_subnet_2_subnet_cidr
  availability_domain = var.lb_subnet_2_availability_domain_name
  subnetCount         = var.add_load_balancer && var.lb_subnet_2_id == "" && var.is_lb_private == "false" && !local.use_regional_subnet && ! local.is_single_ad_region ? 1 : 0
  subnet_id           = var.lb_subnet_2_id
  use_regional_subnet = local.use_regional_subnet
  defined_tags        = local.defined_tags
  freeform_tags       = local.freeform_tags
  prohibit_public_ip  = var.is_lb_private
}

/* Create back end subnet for wls and lb backend */
module "network-bastion-subnet" {
  source = "./modules/network/subnet"

  compartment_ocid = local.network_compartment_id
  tenancy_ocid     = var.tenancy_ocid
  vcn_id           = module.network-vcn.VcnID
  security_list_id = compact(
    concat(
      module.network-vcn-config.wls_security_list_id,
      module.network-vcn-config.wls_ms_security_list_id,
    ),
  )
  dhcp_options_id     = module.network-vcn-config.dhcp_options_id
  route_table_id      = module.network-vcn-config.route_table_id[0]
  subnet_name         = "${local.service_name_prefix}-${var.bastion_subnet_name}"
  dns_label           = "${var.bastion_subnet_name}-${substr(uuid(), -7, -1)}"
  cidr_block          = local.bastion_subnet_cidr
  availability_domain = local.bastion_availability_domain
  subnetCount         = local.assign_weblogic_public_ip == "false" && var.bastion_subnet_id == "" && var.is_bastion_instance_required && var.existing_bastion_instance_id == "" ? 1 : 0
  subnet_id           = var.bastion_subnet_id
  use_regional_subnet = local.use_regional_subnet
  prohibit_public_ip  = "false"
  defined_tags        = local.defined_tags
  freeform_tags       = local.freeform_tags
}

module "bastion-compute" {
  source = "./modules/compute/bastion-instance"

  tenancy_ocid        = var.tenancy_ocid
  compartment_ocid    = local.compartment_ocid
  availability_domain = local.bastion_availability_domain
  ssh_public_key      = var.ssh_public_key
  bastion_subnet_ocid = module.network-bastion-subnet.subnet_id
  instance_shape      = var.bastion_instance_shape
  instance_count      = local.assign_weblogic_public_ip == "false" ? 1 : 0
  is_bastion_instance_required = var.is_bastion_instance_required
  existing_bastion_instance_id = var.existing_bastion_instance_id
  region                       = var.region
  instance_name                = "${local.service_name_prefix}-bastion-instance"
  instance_image_id            = var.mp_baselinux_instance_image_id

  defined_tags  = local.defined_tags
  freeform_tags = local.freeform_tags
  vm_count            = var.wls_node_count
  use_existing_subnet = var.bastion_subnet_id != ""
}

/* Create back end  private subnet for wls */
module "network-wls-private-subnet" {
  source = "./modules/network/subnet"

  compartment_ocid = local.network_compartment_id
  tenancy_ocid     = var.tenancy_ocid
  vcn_id           = module.network-vcn.VcnID
  security_list_id = compact(
    concat(
      module.network-vcn-config.wls_bastion_security_list_id,
      module.network-vcn-config.wls_internal_security_list_id,
      module.network-vcn-config.wls_ms_security_list_id
    ),
  )
  dhcp_options_id     = module.network-vcn-config.dhcp_options_id
  route_table_id      = module.network-vcn-config.service_gateway_route_table_id
  subnet_name         = "${local.service_name_prefix}-${var.wls_subnet_name}"
  dns_label            = format("%s-%s",substr(var.service_name, 0, 4), var.wls_subnet_name)
  cidr_block          = local.wls_subnet_cidr
  availability_domain = var.wls_availability_domain_name
  is_vcn_peered       = local.is_vcn_peering
  subnetCount         = local.assign_weblogic_public_ip == "false" && var.wls_subnet_id == "" ? 1 : 0
  subnet_id           = var.wls_subnet_id
  prohibit_public_ip  = "true"
  use_regional_subnet = local.use_regional_subnet
  defined_tags        = local.defined_tags
  freeform_tags       = local.freeform_tags
}

/* Create back end  public subnet for wls */
module "network-wls-public-subnet" {
  source = "./modules/network/subnet"

  compartment_ocid = local.network_compartment_id
  tenancy_ocid     = var.tenancy_ocid
  vcn_id           = module.network-vcn.VcnID
  security_list_id = compact(
    concat(
      module.network-vcn-config.wls_security_list_id,
      module.network-vcn-config.wls_ms_security_list_id,
      module.network-vcn-config.wls_internal_security_list_id
    ),
  )
  dhcp_options_id      = module.network-vcn-config.dhcp_options_id
  route_table_id       = module.network-vcn-config.route_table_id[0]
  subnet_name          = "${local.service_name_prefix}-${var.wls_subnet_name}"
  dns_label            = format("%s-%s",substr(var.service_name, 0, 4), var.wls_subnet_name)
  cidr_block           = local.wls_subnet_cidr
  availability_domain  = var.wls_availability_domain_name
  is_vcn_peered        = local.is_vcn_peering
  subnetCount          = local.assign_weblogic_public_ip == "true" && var.wls_subnet_id == "" ? 1 : 0
  subnet_id            = var.wls_subnet_id
  prohibit_public_ip   = "false"
  use_existing_subnets = local.use_existing_subnets
  use_regional_subnet  = local.use_regional_subnet
  defined_tags         = local.defined_tags
  freeform_tags        = local.freeform_tags
}

module "network-dns-vms" {
  source = "./modules/network/vcn-peering"

  tenancy_ocid           = var.tenancy_ocid
  compartment_ocid       = var.compartment_ocid
  network_compartment_id = var.network_compartment_id
  instance_shape         = local.dns_instance_shape
  region                 = var.region
  instance_image_id      = var.mp_baselinux_instance_image_id
  service_name           = local.service_name_prefix

  wls_availability_domain = local.wls_availability_domain
  ssh_public_key          = var.ssh_public_key

  wls_vcn_id          = module.network-vcn.VcnID
  wls_vcn_cidr        = module.network-vcn.VcnCIDR
  wls_vcn_name        = var.wls_vcn_name
  use_existing_subnet = local.use_existing_subnets

  ocidb_dbsystem_id     = trimspace(var.ocidb_dbsystem_id)
  ocidb_database_id     = var.ocidb_database_id
  ocidb_compartment_id  = local.ocidb_compartment_id
  ocidb_existing_vcn_id = var.ocidb_existing_vcn_id

  // VCN peering param
  is_vcn_peering        = local.is_vcn_peering
  ocidb_dns_subnet_cidr = var.ocidb_dns_subnet_cidr
  wls_dns_subnet_cidr   = var.wls_dns_subnet_cidr

  // Adding dependency on vcn-config module
  service_gateway_id      = module.network-vcn-config.wls_service_gateway_services_id
  wls_internet_gateway_id = module.network-vcn-config.wls_internet_gateway_id
  wls_subnet_id           = local.assign_weblogic_public_ip == "true" ? element(module.network-wls-public-subnet.subnet_id, 0) : element(module.network-wls-private-subnet.subnet_id, 0)

  // Private subnet support
  assign_public_ip             = local.assign_weblogic_public_ip
  use_regional_subnet          = local.use_regional_subnet
  ocidb_network_compartment_id = local.ocidb_network_compartment_id
}

module "validators" {
  source = "./modules/validators"

  original_service_name        = var.service_name
  service_name_prefix          = local.service_name_prefix
  numVMInstances               = var.wls_node_count
  existing_vcn_id              = var.wls_existing_vcn_id
  wls_subnet_cidr              = var.wls_subnet_cidr
  lb_subnet_1_cidr             = var.lb_subnet_1_cidr
  lb_subnet_2_cidr             = var.lb_subnet_2_cidr
  bastion_subnet_cidr          = var.bastion_subnet_cidr
  assign_public_ip             = local.assign_weblogic_public_ip
  is_bastion_instance_required = var.is_bastion_instance_required
  existing_bastion_instance_id = var.existing_bastion_instance_id
  bastion_ssh_private_key      = var.bastion_ssh_private_key
  add_load_balancer            = var.add_load_balancer
  is_idcs_selected             = var.is_idcs_selected
  idcs_host                    = var.idcs_host
  idcs_tenant                  = var.idcs_tenant
  idcs_client_id               = var.idcs_client_id
  idcs_client_secret           = var.idcs_client_secret_ocid
  idcs_cloudgate_port          = var.idcs_cloudgate_port

  instance_shape = var.instance_shape

  wls_admin_user     = var.wls_admin_user
  wls_admin_password = var.wls_admin_password_ocid

  wls_nm_port               = var.wls_nm_port
  wls_console_port          = var.wls_admin_port
  wls_console_ssl_port      = var.wls_ssl_admin_port
  wls_ms_port               = var.wls_ms_extern_port
  wls_ms_ssl_port           = var.wls_ms_extern_ssl_port
  wls_cluster_mc_port       = var.wls_cluster_mc_port
  wls_extern_admin_port     = var.wls_extern_admin_port
  wls_extern_ssl_admin_port = var.wls_extern_ssl_admin_port

  wls_availability_domain_name = local.wls_availability_domain
  lb_availability_domain_name1 = local.lb_availability_domain_name1
  lb_availability_domain_name2 = local.lb_availability_domain_name2
  wls_subnet_id                = var.wls_subnet_id
  lb_subnet_1_id               = var.lb_subnet_1_id
  lb_subnet_2_id               = var.lb_subnet_2_id
  bastion_subnet_id            = var.bastion_subnet_id

  // WLS version and edition
  wls_version = var.wls_version
  wls_edition = var.wls_edition
  log_level   = var.log_level
  vcn_name    = var.wls_vcn_name

  // OCI DB Params
  ocidb_compartment_id   = local.ocidb_compartment_id
  ocidb_dbsystem_id      = var.ocidb_dbsystem_id
  ocidb_database_id      = var.ocidb_database_id
  ocidb_pdb_service_name = var.ocidb_pdb_service_name
  is_oci_db              = local.is_oci_db

  // ATP DB Params
  is_atp_db             = local.is_atp_db ? "true" : "false"
  atp_db_level          = var.atp_db_level
  atp_db_id             = var.atp_db_id
  atp_db_compartment_id = var.atp_db_compartment_id

  // Common params
  db_user     = local.db_user
  db_password = local.db_password
  db_port     = var.db_port

  // Network compartments
  network_compartment_id       = var.network_compartment_id
  ocidb_network_compartment_id = local.ocidb_network_compartment_id

  // VCN peering variables
  use_local_vcn_peering = var.use_local_vcn_peering
  ocidb_existing_vcn_id = var.ocidb_existing_vcn_id
  ocidb_dns_subnet_cidr = var.ocidb_dns_subnet_cidr
  wls_dns_subnet_cidr   = var.wls_dns_subnet_cidr

  use_regional_subnet = local.use_regional_subnet

  defined_tag        = var.defined_tag
  defined_tag_value  = var.defined_tag_value
  freeform_tag       = var.free_form_tag
  freeform_tag_value = var.free_form_tag_value
  is_lb_private      = var.is_lb_private
}

resource "oci_load_balancer_load_balancer" "wls-loadbalancer" {
  count          = local.lbCount
  shape          = var.lb_shape
  compartment_id = local.network_compartment_id

  subnet_ids = compact(
    concat(
      compact(module.network-lb-subnet-1.subnet_id),
      compact(module.network-lb-subnet-2.subnet_id),
    ),
  )
  display_name  = "${local.service_name_prefix}-lb"
  is_private    = var.is_lb_private
  defined_tags  = local.defined_tags
  freeform_tags = local.freeform_tags
}

module "compute" {
  source              = "./modules/compute/instance"
  tf_script_version   = file(local.tf_version_file)
  tenancy_ocid        = var.tenancy_ocid
  compartment_ocid    = local.compartment_ocid
  instance_image_ocid = var.instance_image_id
  numVMInstances      = var.wls_node_count
  availability_domain = local.wls_availability_domain
  subnet_ocid               = local.assign_weblogic_public_ip == "true" ? element(module.network-wls-public-subnet.subnet_id,0) : element(module.network-wls-private-subnet.subnet_id,0)
  region                    = var.region
  ssh_public_key            = var.ssh_public_key
  instance_shape            = var.instance_shape
  wls_admin_user            = var.wls_admin_user
  wls_domain_name           = format("%s_domain", local.service_name_prefix)
  wls_admin_password        = var.wls_admin_password_ocid
  compute_name_prefix       = local.service_name_prefix
  volume_name               = var.volume_name
  wls_nm_port               = var.wls_nm_port
  wls_ms_server_name        = format("%s_server_", local.service_name_prefix)
  wls_admin_server_name     = format("%s_adminserver", local.service_name_prefix)
  wls_ms_port               = var.wls_ms_port
  wls_ms_ssl_port           = var.wls_ms_ssl_port
  wls_ms_extern_ssl_port    = var.wls_ms_extern_ssl_port
  wls_ms_extern_port        = var.wls_ms_extern_port
  wls_cluster_name          = format("%s_cluster", local.service_name_prefix)
  wls_machine_name          = format("%s_machine_", local.service_name_prefix)
  wls_extern_admin_port     = var.wls_extern_admin_port
  wls_extern_ssl_admin_port = var.wls_extern_ssl_admin_port
  wls_admin_port            = var.wls_admin_port
  wls_admin_ssl_port        = var.wls_ssl_admin_port
  wls_edition               = var.wls_edition
  wls_subnet_id             = var.wls_subnet_id
  is_idcs_selected          = var.is_idcs_selected
  idcs_host                 = var.idcs_host
  idcs_port                 = var.idcs_port
  idcs_tenant               = var.idcs_tenant
  idcs_client_id            = var.idcs_client_id
  idcs_cloudgate_port       = var.idcs_cloudgate_port
  idcs_app_prefix           = local.service_name_prefix
  idcs_client_secret        = var.idcs_client_secret_ocid
  use_regional_subnet      = local.use_regional_subnet
  allow_manual_domain_extension = var.allow_manual_domain_extension
  add_loadbalancer              = var.add_load_balancer
  is_lb_private                = var.is_lb_private
  load_balancer_id              = var.add_load_balancer ? element(coalescelist(oci_load_balancer_load_balancer.wls-loadbalancer.*.id, list("")), 0):""
  wls_existing_vcn_id       = var.wls_existing_vcn_id

  // DB params - to generate a connect string from the params
  db_user     = local.db_user
  db_password = local.db_password
  db_port     = var.db_port

  // OCI DB params
  ocidb_compartment_id   = local.ocidb_compartment_id
  ocidb_database_id      = var.ocidb_database_id
  ocidb_dbsystem_id      = trimspace(var.ocidb_dbsystem_id)
  ocidb_pdb_service_name = var.ocidb_pdb_service_name

  //OCI DB params for adding wls seclist on db subnent
  network_compartment_id         = var.network_compartment_id
  wls_subnet_cidr                = local.wls_subnet_cidr
  service_name_prefix            = local.service_name_prefix
  ocidb_existing_vcn_add_seclist = var.ocidb_existing_vcn_add_seclist
  ocidb_network_compartment_id   = local.ocidb_network_compartment_id
  ocidb_existing_vcn_id          = var.ocidb_existing_vcn_id

  // ATP DB params
  atp_db_level = var.atp_db_level
  atp_db_id    = trimspace(var.atp_db_id)

  // Dev or Prod mode
  mode      = var.mode
  log_level = var.log_level

  deploy_sample_app = local.deploy_sample_app

  // WLS version and artifacts
  wls_version = var.wls_version

  // for VCN peering
  is_vcn_peered = module.network-dns-vms.is_vcn_peered ? "true" : "false"

  // required for dependency on WLS DNS VM to be created prior to compute
  wls_dns_vm_ip = module.network-dns-vms.wls_dns_vm_private_ip

  is_bastion_instance_required= var.is_bastion_instance_required

  assign_public_ip   = local.assign_weblogic_public_ip == "true"
  opc_key            = module.compute-keygen.OPCPrivateKey
  oracle_key         = module.compute-keygen.OraclePrivateKey
  defined_tags       = local.defined_tags
  freeform_tags      = local.freeform_tags

  lbip = var.add_load_balancer ? element(coalescelist(oci_load_balancer_load_balancer.wls-loadbalancer.*.ip_addresses, list(list("")))[0], 0) : ""
}

module "policies" {
  source = "./modules/policies"

  tenancy_id      = var.tenancy_ocid
  compartment_id  = var.compartment_ocid
  label_prefix    = local.service_name_prefix
  atp_db          = local.atp_db
  create_policies = var.create_policies
  providers = {
    oci = oci.home
  }
  ocidb_existing_vcn_add_seclist = var.ocidb_existing_vcn_add_seclist
  ocidb_network_compartment_id   = local.ocidb_network_compartment_id
  network_compartment_id         = local.network_compartment_id
  add_loadbalancer               = var.add_load_balancer
}

module "lb" {
  source = "./modules/lb"

  lbCount          = local.lbCount
  add_load_balancer = var.add_load_balancer
  compartment_ocid  = local.network_compartment_id
  tenancy_ocid      = var.tenancy_ocid
  subnet_ocids = compact(
    concat(
      compact(module.network-lb-subnet-1.subnet_id),
      compact(module.network-lb-subnet-2.subnet_id),
    ),
  )
  instance_private_ips          = module.compute.InstancePrivateIPs
  wls_ms_port                   = var.wls_ms_extern_port
  numVMInstances                = var.wls_node_count
  name                          = "${local.service_name_prefix}-lb"
  lb_backendset_name            = "${local.service_name_prefix}-lb-backendset"
  shape                         = var.lb_shape
  is_idcs_selected              = var.is_idcs_selected
  idcs_cloudgate_port           = var.idcs_cloudgate_port
  defined_tags                  = local.defined_tags
  freeform_tags                 = local.freeform_tags
  is_private                    = var.is_lb_private
  allow_manual_domain_extension = var.allow_manual_domain_extension
  load_balancer_id              = var.add_load_balancer?element(coalescelist(oci_load_balancer_load_balancer.wls-loadbalancer.*.id, list("")), 0):""
}

module "provisioners" {
  source = "./modules/provisioners"
  providers = {
    oci = oci.home
  }
  ssh_private_key = module.compute-keygen.OPCPrivateKey["private_key_pem"]
  host_ips = coalescelist(
    compact(module.compute.InstancePublicIPs),
    compact(module.compute.InstancePrivateIPs),
    list("")
  )
  numVMInstances           = var.wls_node_count
  is_atp_db                = local.is_atp_db ? "true" : "false"
  atp_db_id                = var.atp_db_id
  mode                     = var.mode
  bastion_host_private_key = var.existing_bastion_instance_id == "" ? module.bastion-compute.bastion_private_ssh_key : file(var.bastion_ssh_private_key)
  bastion_host             = var.existing_bastion_instance_id == "" ? join("", module.bastion-compute.publicIp): data.oci_core_instance.existing_bastion_instance[0].public_ip
  assign_public_ip         = local.assign_weblogic_public_ip
  is_bastion_instance_required = var.is_bastion_instance_required
  oracle_key               = module.compute-keygen.OraclePrivateKey

  #added to create module dependency between policy and provisioner to make sure that policy is created before
  # starting provisioning
  secrets_policy_id            = module.policies.wlsc_secret-service-policy_id
  atp_policy_id                = module.policies.wlsc_atp-policy_id
  existing_bastion_instance_id = var.existing_bastion_instance_id
}
