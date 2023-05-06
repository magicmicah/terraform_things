
# oci_environment is a variable that is used to determine which environment to deploy to. This is then used as a key for all the variables.
variable "oci_environment" {
  description = "The environment to deploy to. Valid values are environment1, environment2"
  type = string
  validation {
    condtion = var.oci_environment == "environment1" || var.oci_environment == "environment2"
  }
}

variable "user_ocid" {
}

variable "compartment_ocid" {
}

variable "tenancy_ocid" {
  default = {
    environment1 = "ocid1.tenancy.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    environment2 = "ocid1.tenancy.oc1..bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  }
}

variable "region" {
  default = {
    environment1 = "us-ashburn-1"
    environment2 = "us-phoenix-1"
  }
}

variable "vcn_ocid" {
  default = {
    environment1 = "ocid1.vcn.oc1.iad.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    environment2 = "ocid1.vcn.oc1.phx.bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  }
}

variable "availability_domain" {
  default = 1
}

variable "shape" {
  default = "VM.Standard.E4.Flex"
}

variable "shape_ocpus" {
  default = 1
}

variable "shape_memory" {
  default = 8
}

variable "instance_name" {
  default = "ocihost001"
}

variable "app_name" {
}

variable instance_image_ocid {
  type    = map(string)
  default = {
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    us-phoenix-1 = "ocid1.image.oc1.phx.bb"
    }
}