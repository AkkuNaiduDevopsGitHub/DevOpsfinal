###create a public ip for our lb
resource "azurerm_public_ip" "web_lbpublicip" {
  name                = "${local.resource_name_prefix}-lbpublicip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}
###create the standard load balancer
resource "azurerm_lb" "web_lb" {
  name                = "${local.resource_name_prefix}-web-lb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  #this frontend ip confoiguration will be attached with the publci ip created earlier
  frontend_ip_configuration {
    name                 = "web-lb-public-ip-1"
    public_ip_address_id = azurerm_public_ip.web_lbpublicip.id
  }
}
#backedn pool
#this backend address poll need to attached 
resource "azurerm_lb_backend_address_pool" "web_lb_backend_address_pool" {
  loadbalancer_id = azurerm_lb.web_lb.id
  name            = "web-backend"
}
##3lb probe health checkup
resource "azurerm_lb_probe" "example" {
  loadbalancer_id = azurerm_lb.web_lb.id
  name            = "http-port"
  port            = 80
}
#lb rule
resource "azurerm_lb_rule" "example" {
  loadbalancer_id                = azurerm_lb.web_lb.id
  name                           = "web-app-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.web_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web_lb_backend_address_pool.id]
  probe_id                       = azurerm_lb_probe.example.id

}

output "web_lb_public_ip_address" {
  description = "Web Load Balancer Public Ip"
  value = azurerm_public_ip.web_lbpublicip.ip_address
}
#3associate the nic card with your load balancer. 
/*
resource "azurerm_network_interface_backend_address_pool_association" "web_nic_lb_associate" {
  for_each = var.web_linux_instance_count
  network_interface_id    = azurerm_network_interface.web_linux_vm_nic[each.key].id 
  ip_configuration_name   = azurerm_network_interface.web_linux_vm_nic[each.key].ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.web_lb_backend_address_pool.id
}

 */