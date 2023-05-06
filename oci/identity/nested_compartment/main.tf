// Copyright (c) 2017, 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0

/*
 * This example demonstrates how to work with nested compartments.
 * It has been enhanced to use a map variable to define the compartments.
 */

variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "parent_compartment" {
  type = map(any)
  default = {
    name        = "parent-compartment1"
    description = "compartment that holds a compartment"
  }
}

variable "child_compartments" {
  type = map(any)
  default = {
    child-compartment1 = {
      name           = "child-compartment1"
      description    = "compartment inside another compartment"
      compartment_id = "parent-compartment1"
    }
    child-compartment2 = {
      name           = "child-compartment2"
      description    = "compartment inside another compartment"
      compartment_id = "parent-compartment1"
    }
    child-compartment-2-1 = {
      name           = "child-compartment-2-1"
      description    = "compartment inside another compartment"
      compartment_id = "child-compartment2"
    }
  }
}

variable "enable_delete" {
  default = true
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

resource "oci_identity_compartment" "parent-compartment" {
  name           = var.parent_compartment["name"]
  description    = var.parent_compartment["description"]
  compartment_id = var.tenancy_ocid
  enable_delete  = var.enable_delete
}

resource "oci_identity_compartment" "child-compartments" {
  for_each       = var.child_compartments
  name           = each.value.name
  description    = each.value.description
  compartment_id = oci_identity_compartment.parent-compartment.id
  enable_delete  = var.enable_delete
}

output "parent_compartment" {
  value = [oci_identity_compartment.parent-compartment.id, oci_identity_compartment.parent-compartment.name, oci_identity_compartment.parent-compartment.description]
}

output "child_compartments" {
  # value = oci_identity_compartment.child-compartment
  value = {
    for k, v in oci_identity_compartment.child-compartments : k => [v.id, v.name, v.description]
  }
}

