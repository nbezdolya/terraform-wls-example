/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

// WLS instance with ATP DB
resource "oci_core_instance" "wls-atp-instance" {
  count = local.is_atp_db? var.numVMInstances: 0

  availability_domain = var.use_regional_subnet?local.ad_names[count.index % length(local.ad_names)]:var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${local.host_label}-${count.index}"
  shape               = var.instance_shape

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    display_name     = "primaryvnic"
    assign_public_ip = var.assign_public_ip
    hostname_label   = "${local.host_label}-${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  # Apply the following flag only if you wish to preserve the attached boot volume upon destroying this instance
  # Setting this and destroying the instance will result in a boot volume that should be managed outside of this config.
  # When changing this value, make sure to run 'terraform apply' so that it takes effect before the resource is destroyed.
  #preserve_boot_volume = true

  metadata = {
    service_name                       = var.compute_name_prefix
    tf_script_version                  = var.tf_script_version
    ssh_authorized_keys                = var.ssh_public_key
    wls_admin_user                     = var.wls_admin_user
    wls_admin_password_ocid            = var.wls_admin_password
    wls_domain_name                    = var.wls_domain_name
    is_admin_instance                  = count.index == 0 ? "true" : "false"
    wls_ext_admin_port                 = var.wls_extern_admin_port
    wls_secured_ext_admin_port         = var.wls_extern_ssl_admin_port
    wls_admin_port                     = var.wls_admin_port
    wls_admin_ssl_port                 = var.wls_admin_ssl_port
    wls_nm_port                        = var.wls_nm_port
    host_index                         = count.index
    wls_admin_host                     = "${local.host_label}-0"
    wls_admin_server_wait_timeout_mins = var.wls_admin_server_wait_timeout_mins
    wls_ms_ssl_port                    = var.wls_ms_ssl_port
    wls_ms_port                        = var.wls_ms_port
    wls_ms_extern_port                 = var.wls_ms_extern_port
    wls_ms_extern_ssl_port             = var.wls_ms_extern_ssl_port
    wls_ms_server_name                 = var.wls_ms_server_name
    wls_admin_server_name              = var.wls_admin_server_name
    wls_cluster_name                   = var.wls_cluster_name
    wls_cluster_mc_port                = var.wls_cluster_mc_port
    wls_machine_name                   = var.wls_machine_name
    total_vm_count                     = var.numVMInstances
    allow_manual_domain_extension      = var.allow_manual_domain_extension
    load_balancer_id                   = var.load_balancer_id
    add_loadbalancer                   = var.add_loadbalancer
    is_lb_private                      = var.is_lb_private
    assign_public_ip                   = var.assign_public_ip
    wls_existing_vcn_id                = var.wls_existing_vcn_id
    is_bastion_instance_required       = var.is_bastion_instance_required

    wls_edition = var.wls_edition

    // DB Password OCID
    db_password_ocid = var.db_password
    // OCI DB params
    db_is_oci_db = local.is_oci_db
    db_name = data.oci_database_autonomous_database.atp_db[0].db_name
    db_user = var.db_user

    // RCU params
    rcu_component_list = var.wls_version_to_rcu_component_list_map[var.wls_version]

    //ATP DB Related params
    is_atp_db    = local.is_atp_db
    atp_db_level = var.atp_db_level
    # Whether this is ATP-D or ATP-S?
    is_atp_dedicated = lookup(data.oci_database_autonomous_database.atp_db[0],"is_dedicated")

    user_data = data.template_cloudinit_config.config.rendered

    mode                 = var.mode
    wls_version          = var.wls_version
    fmiddleware_zip      = var.wls_version_to_fmw_map[var.wls_version]
    jdk_zip              = var.wls_version_to_jdk_map[var.wls_version]
    vmscripts_path       = var.vmscripts_path
    log_level            = var.log_level
    mw_vol_mount_point                 = lookup(var.volume_map[0], "volume_mount_point")
    mw_vol_device                      = lookup(var.volume_map[0], "device")
    data_vol_mount_point               = lookup(var.volume_map[1], "volume_mount_point")
    data_vol_device                    = lookup(var.volume_map[1], "device")

    deploy_sample_app                  = var.deploy_sample_app
    domain_dir                         = var.domain_dir
    logs_dir                           = var.logs_dir
    apply_JRF                          = local.is_apply_JRF
    status_check_timeout_duration_secs = var.status_check_timeout_duration_secs

    // For VCN peering
    is_vcn_peered      = false
    atp_db_id          = var.atp_db_id

    // For IDCS
    is_idcs_selected                    = var.is_idcs_selected
    idcs_host                           = var.idcs_host
    idcs_port                           = var.idcs_port
    is_idcs_internal                    = var.is_idcs_internal
    is_idcs_untrusted                   = var.is_idcs_untrusted
    idcs_ip                             = var.idcs_ip
    idcs_tenant                         = var.idcs_tenant
    idcs_client_id                      = var.idcs_client_id
    idcs_client_secret_ocid             = var.idcs_client_secret
    idcs_app_prefix                     = var.idcs_app_prefix
    idcs_cloudgate_port                 = var.idcs_cloudgate_port
    idcs_artifacts_file                 = var.idcs_artifacts_file
    idcs_conf_app_info_file             = var.idcs_conf_app_info_file
    idcs_ent_app_info_file              = var.idcs_ent_app_info_file
    idcs_cloudgate_info_file            = var.idcs_cloudgate_info_file
    idcs_cloudgate_config_file          = var.idcs_cloudgate_config_file
    lbip                                = var.lbip
    idcs_cloudgate_docker_image_tar     = var.idcs_cloudgate_docker_image_tar
    idcs_cloudgate_docker_image_version = var.idcs_cloudgate_docker_image_version
    idcs_cloudgate_docker_image_name    = var.idcs_cloudgate_docker_image_name
  }
  #if there is only 1 AD or AD subnets are used, spread VM across FDs,
  #however for more than one AD spread VMs across ADs  and let system select the FD in the respective ADs
  fault_domain = (length(local.ad_names)==1 || !var.use_regional_subnet)?lookup(data.oci_identity_fault_domains.wls_fault_domains.fault_domains[(count.index + 1) % local.num_fault_domains], "name"):""
  timeouts {
    create = "${var.provisioning_timeout_mins}m"
  }

  #prevent any metadata changes to destroy instance
  lifecycle {
    ignore_changes = [metadata]
  }
}
