# Copyright 2020, Oracle Corporation and/or affiliates.  All rights reserved.

output "wlsc_secret-service-policy_id" {
  value = var.create_policies ? element(concat(oci_identity_policy.wlsc_secret-service-policy[0].*.id, list("")),0) : ""
}


output "wlsc_atp-policy_id" {
  value = var.create_policies && var.atp_db.is_atp ? element(concat(oci_identity_policy.wlsc_atp-policy[0].*.id, list("")),0) : ""
}