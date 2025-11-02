vms = {
  vm1 = {
    rg_name     = "rg-dev-todoapp"
    location = "Central India"
    vnet_name   = "vnet-dev-todoapp"
    subnet_name = "frontend-subnet"
    pip_name    = "pip"
    nic_name    = "nic-dev-todoapp"
    vm_name     = "vm-dev-todoapp"
    size        = "Standard_B1s"

    admin_username = "azureuser"
    admin_password = "Password@123"

    source_image_reference = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
    }
  }
}
