variable "vms" {}
data "azurerm_subnet" "subnet" {
  for_each             = var.vms
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.rg_name
}

data "azurerm_public_ip" "pip" {
  for_each            = var.vms
  name                = each.value.pip_name
  resource_group_name = each.value.rg_name
}

resource "azurerm_resource_group" "rg" {
  for_each = var.vms
  name     = each.value.rg_name
  location = each.value.location
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = var.vms
  name                = each.value.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = each.value.location
  resource_group_name = each.value.rg_name
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.vms
  name                 = each.value.subnet_name
  resource_group_name  = each.value.rg_name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = ["10.0.${10 + index(keys(var.vms), each.key)}.0/24"]
}

resource "azurerm_public_ip" "pip" {
  for_each            = var.vms
  name                = each.value.pip_name
  location            = each.value.location
  resource_group_name = each.value.rg_name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}


resource "azurerm_network_interface" "nic" {
  for_each            = var.vms
  name                = each.value.nic_name
  location            = each.value.location
  resource_group_name = each.value.rg_name

 ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = data.azurerm_public_ip.pip[each.key].id
  }
}

# resource "azurerm_network_interface" "nic" {
#   for_each            = var.vms
#   name                = each.value.nic_name
#   location            = each.value.location
#   resource_group_name = each.value.rg_name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.subnet[each.key].id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.pip[each.key].id
#   }
# }

resource "azurerm_linux_virtual_machine" "vm" {
  for_each                        = var.vms
  name                            = each.value.vm_name
  resource_group_name             = each.value.rg_name
  location                        = each.value.location
  size                            = each.value.size != "" ? each.value.size : "Standard_B1s"
   admin_username                  = each.value.admin_username != "" ? each.value.admin_username : "azureuser"
  admin_password                  = each.value.admin_password != "" ? each.value.admin_password : "Password@123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }
}

# resource "azurerm_linux_virtual_machine" "vm" {
#   for_each                        = var.vms
#   name                            = each.value.vm_name
#   resource_group_name             = each.value.rg_name
#   location                        = each.value.location
#   size                            = each.value.size != "" ? each.value.size : "Standard_B1s"
#   admin_username                  = each.value.admin_username != "" ? each.value.admin_username : "azureuser"
#   admin_password                  = each.value.admin_password != "" ? each.value.admin_password : "Password@123"
#   disable_password_authentication = false

#   network_interface_ids = [
#     azurerm_network_interface.nic[each.key].id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = each.value.source_image_reference.publisher
#     offer     = each.value.source_image_reference.offer
#     sku       = each.value.source_image_reference.sku
#     version   = each.value.source_image_reference.version
#   }
# }