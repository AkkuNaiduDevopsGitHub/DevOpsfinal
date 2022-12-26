locals {
  webvm_custom_data = <<CUSTOM_DATA
#!/bin/sh
#sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd  
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo chmod -R 777 /var/www/html 
sudo echo "Welcome to cloud4 - WebVM App1 - VM Hostname: $(hostname)" > /var/www/html/index.html
sudo mkdir /var/www/html/app1
sudo echo "Welcome to cloud4 - WebVM App1 - VM Hostname: $(hostname)" > /var/www/html/app1/hostname.html
sudo echo "Welcome to cloud4 - WebVM App1 - App1 Status Page" > /var/www/html/app1/status.html
sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(250, 210, 210);"> <h1>Welcome to cloud4 - WebVM APP-1 </h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /var/www/html/app1/index.html
sudo curl -H "Metadata:true" --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2020-09-01" -o /var/www/html/app1/metadata.html
CUSTOM_DATA
}
/*data "azurerm_shared_image" "example" {
  name                = "avd-image"
  gallery_name        = "sigyeiu"
  resource_group_name = "rg-shared-resources1"
}*/
resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name                = "${local.resource_name_prefix}-web-vmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  instances           = 2
  sku                = "Standard_DS1_V2"
  admin_username      = "azureuser"
  

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${path.module}/ssh-keys/terraform-azure.pub")
  }

  /*storage_image_reference {
        id = "${data.azurerm_shared_image.example.id}"
    }*/
  //source_image_id = data.azurerm_shared_image.example.id
  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "83-gen2"
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }
  upgrade_mode = "Automatic"
  network_interface {
    name                      = "web-vmss-nic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.web_vmss_nsg.id
    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.websubnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web_lb_backend_address_pool.id]
    }
  }

  /*source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "83-gen2"
    version   = "latest"
  }*/
  custom_data = base64encode(local.webvm_custom_data)
  #custom_data = filebase64(${path.module}/app-scripts/redhat-vm-script.sh)
}