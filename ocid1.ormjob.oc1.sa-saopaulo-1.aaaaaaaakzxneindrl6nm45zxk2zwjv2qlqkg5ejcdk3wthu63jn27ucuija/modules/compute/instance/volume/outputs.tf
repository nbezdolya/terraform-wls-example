/*
 * Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
 */

output "DataVolumeOcids" {
  value = oci_core_volume.wls-block-volume.*.id
}
