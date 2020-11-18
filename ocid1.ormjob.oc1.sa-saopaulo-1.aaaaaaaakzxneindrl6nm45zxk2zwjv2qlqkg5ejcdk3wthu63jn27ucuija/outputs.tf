/*
 * Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
 */

# Output the private and public IPs of the instance
locals {
  admin_ip_address = local.assign_weblogic_public_ip == "true" ? module.compute.InstancePublicIPs[0] : module.compute.InstancePrivateIPs[0]
  admin_console_app_url = format(
    "https://%s:%s/console",
    local.admin_ip_address,
    var.wls_extern_ssl_admin_port,
  )
  fmw_console_app_url = local.requires_JRF ? format(
    "https://%s:%s/em",
    local.admin_ip_address,
    var.wls_extern_ssl_admin_port,
  ) : ""
  sample_app_protocol = var.add_load_balancer ? "https" : "http"
  sample_app_url_wls_ip = var.deploy_sample_app == "true" ? format(
    "https://%s:%s/sample-app",
    local.admin_ip_address,
    var.wls_ms_extern_ssl_port,
  ) : ""
  sample_app_url_lb_ip = var.deploy_sample_app == "true" && var.add_load_balancer ? format(
    "%s://%s/sample-app",
    local.sample_app_protocol,
    element(coalescelist(oci_load_balancer_load_balancer.wls-loadbalancer.*.ip_addresses, list(list("")))[0], 0),
  ) : ""
  sample_app_url = var.wls_edition != "SE" ? (var.deploy_sample_app == "true" && var.add_load_balancer ? local.sample_app_url_lb_ip : local.sample_app_url_wls_ip) : ""
  sample_idcs_app_url = var.deploy_sample_app == "true" && var.add_load_balancer && var.is_idcs_selected == "true" ? format(
    "%s://%s/__protected/idcs-sample-app",
    local.sample_app_protocol,
    element(coalescelist(oci_load_balancer_load_balancer.wls-loadbalancer.*.ip_addresses, list(list("")))[0], 0),
  ) : ""

  #used in outputs to display appropriate edition name
  edition_map = zipmap(
    ["SE", "EE", "SUITE"],
    ["Standard Edition", "Enterprise Edition", "Suite Edition"],
  )
  async_prov_mode = !var.is_bastion_instance_required ? "Asynchronous provisioning is enabled. Connect to each compute instance and confirm that the file /u01/provisioningCompletedMarker exists. Details are found in the file /u01/logs/provisioning.log." : ""
}

output "Virtual_Cloud_Network_Id" {
  value = module.network-vcn.VcnID
}

output "Virtual_Cloud_Network_CIDR" {
  value = module.network-vcn.VcnCIDR
}

output "Is_VCN_Peered" {
  value = local.is_vcn_peering
}

output "Loadbalancer_Subnets_Id" {
  value = compact(
    concat(
      module.network-lb-subnet-1.subnet_id,
      module.network-lb-subnet-2.subnet_id,
    ),
  )
}

output "Weblogic_Subnet_Id" {
  value = distinct(
    compact(
      concat(
        module.network-wls-public-subnet.subnet_id,
        module.network-wls-private-subnet.subnet_id,
      ),
    ),
  )
}

output "Load_Balancer_Ip" {
  value = flatten(element(coalescelist(oci_load_balancer_load_balancer.wls-loadbalancer.*.ip_addresses, list(list(""))), 0))
}

locals {
  new_bastion_details=join(" ", formatlist(
    "{\n       \"Instance Id\":\"%s\",\n       \"Instance Name\":\"%s\",\n       \"Private IP\":\"%s\",\n       \"Public IP\":\"%s\"\n       }",
    module.bastion-compute.id,
    module.bastion-compute.display_name,
    module.bastion-compute.privateIp,
    module.bastion-compute.publicIp,
  ))

  existing_bastion_details=join(" ", formatlist(
    "{\n       \"Instance Id\":\"%s\",\n       \"Instance Name\":\"%s\",\n       \"Private IP\":\"%s\",\n       \"Public IP\":\"%s\"\n       }",
    data.oci_core_instance.existing_bastion_instance.*.id,
    data.oci_core_instance.existing_bastion_instance.*.display_name,
    data.oci_core_instance.existing_bastion_instance.*.private_ip,
    data.oci_core_instance.existing_bastion_instance.*.public_ip
  ))
}

output "Bastion_Instance" {
  value = var.existing_bastion_instance_id==""?local.new_bastion_details: local.existing_bastion_details
}

output "Weblogic_Instances" {
  value = join(" ", formatlist(
    "{\n       \"Instance Id\":\"%s\",\n       \"Instance name\":\"%s\",\n       \"Private IP\":\"%s\",\n       \"Public IP\":\"%s\"\n       }",
    module.compute.InstanceOcids,
    module.compute.display_names,
    module.compute.InstancePrivateIPs,
    module.compute.InstancePublicIPs,
  ))
}

output "Weblogic_Version" {
  value = format(
    "%s %s %s",
    module.compute.WlsVersion,
    local.edition_map[upper(var.wls_edition)],
    local.prov_type,
  )
}

output "Weblogic_Edition" {
  value = var.wls_edition
}

output "WebLogic_Server_Administration_Console" {
  value = local.admin_console_app_url
}

output "Fusion_Middleware_Control_Console" {
  value = local.fmw_console_app_url
}

output "Sample_Application" {
  value = local.sample_app_url
}

output "Sample_Application_protected_by_IDCS" {
  value = local.sample_idcs_app_url
}

output "Listing_Version" {
  value=file(local.tf_version_file)
}

output "Provisioning_Status" {
  value = local.async_prov_mode
}