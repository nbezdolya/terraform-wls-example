/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */


/*
********************
OCI DB Config
********************
*/
// Provide DB node count - for node count > 1, WLS AGL datasource will be created
variable "add_JRF" {
  default = "false"
}

variable "ocidb_compartment_id" {
  default = ""
}

variable "ocidb_network_compartment_id" {
  default = ""
}

variable "ocidb_existing_vcn_id" {
  default = ""
}

variable "ocidb_existing_vcn_add_seclist" {
  type = bool
  default = true
}

variable "ocidb_dbsystem_id" {
  default = ""
}

variable "ocidb_dbhome_id" {
  default = ""
}

variable "ocidb_database_id" {
  default = ""
}

variable "ocidb_pdb_service_name" {
  default = ""
}

variable "oci_db_user" {
  default = ""
}

variable "oci_db_password_ocid" {
  default = ""
}

variable "db_port" {
  default = "1521"
}



/*
********************
ATP Parameters
********************
*/

variable "atp_db_compartment_id" {
  default = ""
}

variable "atp_db_id" {
  default = ""
}

variable "atp_db_level" {
  default = "low"
}

variable "atp_db_password_ocid" {
  default = ""
}