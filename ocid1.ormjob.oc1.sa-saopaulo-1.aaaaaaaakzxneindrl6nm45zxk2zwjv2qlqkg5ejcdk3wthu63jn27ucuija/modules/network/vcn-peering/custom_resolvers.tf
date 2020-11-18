/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

/**
 * Create WLS and OCIDB Custom Resolver DHCP Options in their respective VCNs.
 */

resource "oci_core_default_dhcp_options" "wls-custom-resolver-dhcp-options-newvcn" {
  count                      = var.is_vcn_peering && var.wls_vcn_name != ""? 1:0
  manage_default_resource_id = lookup(data.oci_core_vcns.wls_vcn[0].virtual_networks[0], "default_dhcp_options_id")

  // required
  options {
    type        = "DomainNameServer"
    server_type = "CustomDnsServer"

    custom_dns_servers = [data.oci_core_vnic.wls_vnic-newvcn[0].private_ip_address, "169.254.169.254"]
  }
}

resource "oci_core_default_dhcp_options" "wls-custom-resolver-dhcp-options-existingvcn" {
  count                      = var.is_vcn_peering && var.wls_vcn_name == ""? 1:0
  manage_default_resource_id = lookup(data.oci_core_vcns.wls_vcn[0].virtual_networks[0], "default_dhcp_options_id")

  // required
  options {
    type        = "DomainNameServer"
    server_type = "CustomDnsServer"

    custom_dns_servers = [data.oci_core_vnic.wls_vnic-existingvcn[0].private_ip_address, "169.254.169.254"]
  }
}

/*
 * Modify OCI DB VCN's default DHCP option to use the custom resolver.
 */
resource "oci_core_default_dhcp_options" "ocidb-custom-resolver-dhcp-options" {
  count                      = var.is_vcn_peering ? 1:0
  manage_default_resource_id = lookup(data.oci_core_vcns.ocidb_vcn[0].virtual_networks[0],"default_dhcp_options_id")

  // required
  options {
    type        = "DomainNameServer"
    server_type = "CustomDnsServer"

    custom_dns_servers = [data.oci_core_vnic.ocidb_vnic[0].private_ip_address, "169.254.169.254"]
  }
}
