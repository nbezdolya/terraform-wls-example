/*
 * Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
 */

# Output the private and public IPs of the instance

output "id" {
  value = "${oci_core_instance.wls-bastion-instance.*.id}"
}

output "display_name" {
  value = "${oci_core_instance.wls-bastion-instance.*.display_name}"
}

output "publicIp" {
  value = "${oci_core_instance.wls-bastion-instance.*.public_ip}"
}

output "privateIp" {
  value = oci_core_instance.wls-bastion-instance.*.private_ip
}

output "bastion_private_ssh_key" {
  value = local.bastion_private_ssh_key
}