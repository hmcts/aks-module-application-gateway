# Public Ip 
resource "azurerm_public_ip" "appgw_pip" {
  name                = format("%s-%s-appgw-pip", var.network_shortname, var.deploy_environment)
  location            = var.network_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(
    data.null_data_source.tag_defaults.inputs,
    map(
      "Name", format("%s_%s_network",
        lookup(data.null_data_source.network_defaults.inputs, "name_prefix"),
        lookup(data.null_data_source.tag_defaults.inputs, "Environment")
      )
    )
  )
}