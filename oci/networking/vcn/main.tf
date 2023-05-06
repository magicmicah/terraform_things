// Copyright (c) 2017, 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0

variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "compartment_ocid" {
}

variable "region" {
}

variable "cidr_blocks" {
  type    = list(string)
  default = ["192.168.1.0/24"]
}

variable "dns_label" {
  default = "vcn"
}

variable "display_name" {
  default = "vcn"
}

provider "oci" {

  tenancy_ocid        = var.tenancy_ocid
  user_ocid           = var.user_ocid
  fingerprint         = var.fingerprint
  private_key_path    = var.private_key_path
  region              = var.region
  ignore_defined_tags = ["testexamples-tag-namespace.tf-example-tag"]
}

resource "oci_core_vcn" "vcn" {
  cidr_blocks    = var.cidr_blocks
  dns_label      = var.dns_label
  compartment_id = var.compartment_ocid
  display_name   = var.display_name
}

output "vcn_id" {
  value = oci_core_vcn.vcn.id
}
