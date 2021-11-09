variable "rgname" {
  default = "linuxVMRg"
}
variable "location" {
  default = "eastus"
}
variable "vnetName" {
  default = "linuxVnet"
}
variable "subnetName" {
  default = "linuxSubnet"
}
variable "NSGName" {
  default = "linuxNSG"
}
variable "VM1PublicIPName" {
  default = "linuxIP1"
}
variable "VM2PublicIPName" {
  default = "linuxIP2"
}
variable "linux1NICName" {
  default = "linuxNIC1"
}
variable "linux2NICName" {
  default = "linuxNIC2"
}
variable "vm1Name" {
  default = "linuxVM1"
}
variable "vm2Name" {
  default = "linuxVM2"
}
variable "vnet_address_space" { 
    type = list
    default = ["10.0.0.0/16"]
}

variable "subnet_address_space" { 
    type = list
    default = ["10.0.1.0/24"]
}