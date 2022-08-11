resource "azurerm_virtual_network" "tfub_network" {
  name                = "vnet-${local.name_postfix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_subnet" "tfub_subnet" {
  name                 = "snet-${local.name_postfix}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.tfub_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "tfub_publicip" {
  name                = "pip-${local.name_postfix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = local.dns_name
  tags                = local.tags

}
