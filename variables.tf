variable "region" {
  default = "eu-west-1"
}

variable "accessKey" {
  default = "<<ADD_YOUR_KEY>>"
}

variable "secretKey" {
  default = "<<ADD_YOUR_SECRET>>"
}

variable "availabilityZone" {
  default = "eu-west-1c"
}

variable "instanceTenancy" {
  default = "default"
}

variable "dnsSupport" {
  default = true
}

variable "dnsHostNames" {
  default = true
}

variable "vpcCIDRblock" {
  default = "10.0.0.0/16"
}

variable "subnetCIDRblock" {
  default = "10.0.1.0/24"
}

variable "homeCIDRblock" {
  default = "178.143.35.0/32"
}

variable "homeCIDRblockList" {
  type = "list"
  default = [ "178.143.35.0/32" ]
}

variable "destinationCIDRblock" {
  default = "0.0.0.0/0"
}

variable "ingressCIDRblock" {
  type = "list"
  default = [ "0.0.0.0/0" ]
}

variable "egressCIDRblock" {
  type = "list"
  default = [ "0.0.0.0/0" ]
}

variable "mapPublicIP" {
  default = true
}
