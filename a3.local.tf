locals {
  #the purpose of local value is to do concatinate multiple varaible
  #inside locals block you need to first vall those varaible and store it in a key
  owners      = var.business_devision
  environment = var.environment
  #whenever we want to do concationation of varaible it can be done using a local block
  resource_name_prefix = "${var.business_devision}-${var.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}