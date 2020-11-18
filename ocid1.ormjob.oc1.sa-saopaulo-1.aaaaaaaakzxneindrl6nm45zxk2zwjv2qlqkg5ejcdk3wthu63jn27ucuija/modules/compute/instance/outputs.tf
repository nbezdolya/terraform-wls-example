/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

# Output the private and public IPs of the instance
output "InstancePrivateIPs" {
  value = coalescelist(oci_core_instance.wls-atp-instance.*.private_ip, oci_core_instance.wls_no_jrf_instance.*.private_ip, oci_core_instance.wls_ocidb_instance.*.private_ip, oci_core_instance.wls_ocidb_peered_vcn_instance.*.private_ip, list(""))
}

output "InstancePublicIPs" {
  value = coalescelist(oci_core_instance.wls-atp-instance.*.public_ip, oci_core_instance.wls_no_jrf_instance.*.public_ip, oci_core_instance.wls_ocidb_instance.*.public_ip, oci_core_instance.wls_ocidb_peered_vcn_instance.*.public_ip, list(""))
}

output "InstanceOcids" {
  value = coalescelist(oci_core_instance.wls-atp-instance.*.id, oci_core_instance.wls_no_jrf_instance.*.id, oci_core_instance.wls_ocidb_instance.*.id, oci_core_instance.wls_ocidb_peered_vcn_instance.*.id, list(""))
}

output "display_names" {
  value = coalescelist(oci_core_instance.wls-atp-instance.*.display_name, oci_core_instance.wls_no_jrf_instance.*.display_name, oci_core_instance.wls_ocidb_instance.*.display_name, oci_core_instance.wls_ocidb_peered_vcn_instance.*.display_name, list(""))
}

output "WlsVersion" {
  value = "${var.wls_version}"
}
