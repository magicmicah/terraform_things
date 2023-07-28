variable "tenancy_ocid" {
}

variable "compartment_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "ssh_public_key_file" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_file" {
  default = "~/.ssh/id_rsa"
}

variable "region" {
  default = "us-ashburn-1"
}

variable "instance_image_ocid" {
  type = map(string)
  default = {
    # See https://docs.us-phoenix-1.oraclecloud.com/images/
    # Oracle-provided image "Canonical-Ubuntu-22.04-aarch64-2023.04.19-0"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaat2mbhlbqy5ykmnaildwgtc3opl4umbquj2g674njhtlmy7pjb4ga"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaanetmukvnxijbewnfuw5xqtjfrm5nocv7yy4zy4ayafxolwt435bq"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaue5jpfecikq4kxt467pm4uumjpacnatgza6bjcpfxuiwxoowt3eq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaqm7w47pk5v3iju2vmoo7btthgq3yur2zyvpp4p352jedemxo4hdq"
  }
}

variable "instance_shape" {
  default = "VM.Standard.A1.Flex"
}

variable "instance_shape_config" {
  default = {
    # See https://docs.cloud.oracle.com/iaas/Content/Compute/References/computeshapes.htm
    # for more information on shapes
    "VM.Standard.A1.Flex" = {
      "ocpus"  = 1
      "memory" = 8
    }
  }
}

variable "instance_block_volume_size" {
  default = 100
}

variable "k3s_worker_node_count" {
  default = 2
}

locals {
  ssh_public_key = file(var.ssh_public_key_file)
  ssh_private_key = file(var.ssh_private_key_file)
}