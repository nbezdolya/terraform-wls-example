/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */
# Output of the vcn creation
output "VcnID" {
  description = "ocid of VCN. "
  value       = var.vcn_name!=""?join("",oci_core_virtual_network.wls-vcn.*.id):var.vcn_id
}

output "VcnCIDR" {
  description = "cidr of VCN"
  value       = join("",oci_core_virtual_network.wls-vcn.*.cidr_block)
}
