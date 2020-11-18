/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */
# TEMP WAY OF CREATING ORACLE SSH KEY FOR DEVELOPMENT
resource "tls_private_key" "oracle_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Creating OPC key for script copy
resource "tls_private_key" "opc_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
