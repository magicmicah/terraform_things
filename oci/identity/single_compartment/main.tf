// Copyright (c) 2017, 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0

/*
 * This example file shows how to create a compartment or reference an existing compartment as a resource.
 *
 * Note: the compartment resource internally resolves name collisions and returns a reference to the preexisting
 * compartment by default. Use `enable_delete` to allow compartment deletion and prevent implicitly importing compartments.
 */

variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "compartment_name" {
  default = "tf-example-compartment"
}

variable "enable_delete" {
  default = false
}

resource "oci_identity_compartment" "compartment1" {
  name           = var.compartment_name
  description    = "compartment created by terraform"
  compartment_id = var.tenancy_ocid
  enable_delete  = var.enable_delete // true will cause this compartment to be deleted when running `terrafrom destroy`
}

data "oci_identity_compartments" "compartments1" {
  compartment_id = oci_identity_compartment.compartment1.compartment_id

  filter {
    name   = "name"
    values = [var.compartment_name]
  }
}

output "compartments" {
  value = data.oci_identity_compartments.compartments1.compartments
}
