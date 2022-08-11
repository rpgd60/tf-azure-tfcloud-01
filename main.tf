locals {
  name_postfix = "${var.app_name}-${var.environment}-${var.region}"
  dns_name = var.app_name
  tags = {
    Source          = "terraform"
    Env             = var.environment
    CostCenter      = var.cost_center
    ApplicationName = var.app_name
  }
}

# Random String Resource
resource "random_string" "myrandom" {
  length = 5
  upper = false 
  special = false
  numeric = false   
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name_postfix}"
  location = var.region
  tags     = local.tags
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "tfub_nsg" {
  name                = "nsg-${local.name_postfix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "nsgr-SSH"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.tfub_nsg.name
}

resource "azurerm_network_security_rule" "icmp" {
  name                        = "nsgr-igmp"
  priority                    = 1102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.tfub_nsg.name
}

resource "azurerm_network_security_rule" "http" {
  name                        = "nsgr-http"
  priority                    = 1202
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.tfub_nsg.name
}

# Create network interface
resource "azurerm_network_interface" "tfub_nic" {
  name                = "nic-${local.name_postfix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "NicConfig"
    subnet_id                     = azurerm_subnet.tfub_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfub_publicip.id
  }
  tags = local.tags
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.tfub_nic.id
  network_security_group_id = azurerm_network_security_group.tfub_nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "tfub_vm" {
  depends_on = [
    azurerm_network_interface_security_group_association.example
  ]
  name                  = "vm-${local.name_postfix}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.tfub_nic.id]
  size                  = var.vm_size

  os_disk {
    name                 = "osd-${local.name_postfix}-${random_string.myrandom.result}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku     = "20_04-lts"
    version = "latest"
  }

  custom_data = filebase64("${path.module}/app-scripts/app1-cloud-init.txt")
  computer_name                   = local.dns_name
  admin_username                  = var.ssh_user
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.ssh_pub_key_file)
  }

  # boot_diagnostics {
  #   storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  # }
  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags,             ## Prevents TF from removing tags added to the VM outside of Terraform (e.g. by a mgmt application)
    ]
  }
}