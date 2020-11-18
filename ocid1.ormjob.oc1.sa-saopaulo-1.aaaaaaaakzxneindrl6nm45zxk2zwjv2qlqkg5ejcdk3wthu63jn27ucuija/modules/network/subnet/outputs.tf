# Output of the subnet creation
output "subnet_id" {
  description = "OCID of created subnet. "
  value       = distinct(coalescelist(oci_core_subnet.wls-subnet.*.id, list(var.subnet_id)))
}
