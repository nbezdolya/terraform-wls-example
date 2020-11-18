/*
 * Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
 */

data "oci_identity_compartment" "atp_db" {
  count = var.atp_db.is_atp == true ? 1 : 0
  #Required
  id = var.atp_db.compartment_id
}