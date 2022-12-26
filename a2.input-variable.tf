##generic input varaible. 
#business devision
variable "business_devision" {
  description = "Business devision in large organization"
  type        = string
  default     = "hr"
  ##every varaible can accept single argument
}
#when my resourcegrp created 
#hr-dev-environment-location 
#environment variable 
variable "environment" {
  type    = string
  default = "dev"
}

variable "resource_group" {
  type    = string
  default = "rg-default"
}

variable "resource_group_location" {
  type    = string
  default = "eastus"
}