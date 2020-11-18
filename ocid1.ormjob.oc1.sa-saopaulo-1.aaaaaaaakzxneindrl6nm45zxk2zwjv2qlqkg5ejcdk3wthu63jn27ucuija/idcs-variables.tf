
/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

/*
********************
IDCS Support
********************
*/

variable "is_idcs_selected" {
  default = "false"
}

variable "idcs_host" {
  default = "identity.oraclecloud.com"
}

variable "idcs_port" {
  default = "443"
}

variable "idcs_tenant" {
  default = ""
}

variable "idcs_client_id" {
  default = ""
}

variable "idcs_client_secret_ocid" {
  default = ""
}

variable "idcs_cloudgate_port" {
  default = "9999"
}
