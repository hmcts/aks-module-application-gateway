resource "azurerm_application_gateway" "network" {
  name = format("%s_application_gateway_%s", var.network_shortname, var.deploy_environment)

  resource_group_name = var.resource_group_name
  location            = var.network_location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = data.azurerm_subnet.application_gateway_subnet.id
  }

  frontend_port {
    name = format("%s-%s-appgw-feport", var.network_shortname, var.deploy_environment)
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = format("%s-%s-appgw-feip", var.network_shortname, var.deploy_environment)
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = format("%s-%s-appgw-beap", var.network_shortname, var.deploy_environment)
  }

  backend_http_settings {
    name                  = format("%s-%s-appgw-be-htst", var.network_shortname, var.deploy_environment)
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = format("%s-%s-appgw-httplstn", var.network_shortname, var.deploy_environment)
    frontend_ip_configuration_name = format("%s-%s-appgw-feip", var.network_shortname, var.deploy_environment)
    frontend_port_name             = format("%s-%s-appgw-feport", var.network_shortname, var.deploy_environment)
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = format("%s-%s-appgw-rqrt", var.network_shortname, var.deploy_environment)
    rule_type                  = "Basic"
    http_listener_name         = format("%s-%s-appgw-httplstn", var.network_shortname, var.deploy_environment)
    backend_address_pool_name  = format("%s-%s-appgw-beap", var.network_shortname, var.deploy_environment)
    backend_http_settings_name = format("%s-%s-appgw-be-htst", var.network_shortname, var.deploy_environment)
  }

  tags = merge(
    data.null_data_source.tag_defaults.inputs,
    map(
      "Name", format("%s_%s_network",
        lookup(data.null_data_source.network_defaults.inputs, "name_prefix"),
        lookup(data.null_data_source.tag_defaults.inputs, "Environment")
      )
    )
  )

  #depends_on = [azurerm_virtual_network.test, azurerm_public_ip.test]
}
