#3create a null resource and provisioned. 
resource "null_resource" "null_resource_to_copy_ssh" {
  ##connection block we will create
  connection {
    type = "ssh"
    host = azurerm_linux_virtual_machine.bstion_linuxvm.public_ip_address
    user = azurerm_linux_virtual_machine.bstion_linuxvm.admin_username
    private_key = file("${path.module}/ssh-keys/terraform-azure.pem")
  }

  ##we will use a file provisioner is like an trigger
  provisioner "file" {
    source = "ssh-keys/terraform-azure.pem"
    destination = "/tmp/terraform-azure.pem"
  }

  ##to change permissione we need to execute command remote execution

  provisioner "remote-exec" {
    inline = [
        "sudo chmod 400 /tmp/terraform-azure.pem "
    ]
  }

}