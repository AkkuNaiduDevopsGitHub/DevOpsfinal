resource "azurerm_public_ip" "bastion_linux_publicip" {
  name = "${local.resource_name_prefix}-bastion-linux-publicip"
  resource_group_name = azurerm_resource_group.rg.name 
  location = azurerm_resource_group.rg.location
  allocation_method = "Static"
  sku = "Standard"
  
}


resource "azurerm_network_interface" "bastion_linux_vm_nic" {
  name = "${local.resource_name_prefix}-bastion-linux-nic"
  resource_group_name = azurerm_resource_group.rg.name 
  location = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "bastion-linux"
    subnet_id                     = azurerm_subnet.bastionsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.bastion_linux_publicip.id
  }
}

resource "azurerm_linux_virtual_machine" "bstion_linuxvm" {
  name                = "${local.resource_name_prefix}-bastion-linux-vm"
  resource_group_name = azurerm_resource_group.rg.name 
  location = azurerm_resource_group.rg.location
  size                = "Standard_DS1_V2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.bastion_linux_vm_nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${path.module}/ssh-keys/terraform-azure.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
   
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "83-gen2"
    version   = "latest"
  }
  #custom_data = base64encode(local.webvm_custom_data)
  #custom_data = filebase64(${path.module}/app-scripts/redhat-vm-script.sh)
}