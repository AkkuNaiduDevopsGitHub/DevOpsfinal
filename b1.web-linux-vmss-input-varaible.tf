variable "web_vmss_nsg_inbound_ports" {
  type    = list(string)
  default = [22, 80, 443]
}