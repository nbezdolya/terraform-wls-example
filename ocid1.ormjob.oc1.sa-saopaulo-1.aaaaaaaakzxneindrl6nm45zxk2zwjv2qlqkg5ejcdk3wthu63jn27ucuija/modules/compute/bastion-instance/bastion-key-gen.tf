/*
 * Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
 */

# Creating OPC key bastion host
# Either key1 or key2 is used based on the number of node count.
# This is work around to trigger creation of new bastion for scale out.

resource "tls_private_key" "bastion_opc_key" {
  count = var.use_existing_subnet?var.vm_count:1
  algorithm = "RSA"
  rsa_bits  = 4096
}