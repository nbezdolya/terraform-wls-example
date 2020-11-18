/*
 * Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
 */

locals {
  bastion_public_ssh_key=var.use_existing_subnet?tls_private_key.bastion_opc_key[var.vm_count - 1].public_key_openssh: tls_private_key.bastion_opc_key[0].public_key_openssh
  bastion_private_ssh_key=var.use_existing_subnet?tls_private_key.bastion_opc_key[var.vm_count - 1].private_key_pem: tls_private_key.bastion_opc_key[0].private_key_pem
}

# Gets a list of Availability Domains in the tenancy
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}


data "template_file" "bastion_key_script" {
  template = "${file("./modules/compute/bastion-instance/templates/bastion-keys.tpl")}"

  vars = {
    pubKey     = local.bastion_public_ssh_key
  }
}
