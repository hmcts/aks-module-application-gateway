resource "azurerm_application_gateway" "network" {
  name = format("%s_application_gateway_%s", var.network_shortname, var.deploy_environment)
  resource_group_name = var.resource_group_name
  location            = var.location

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
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "${local.frontend_ip_configuration_name}_public"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  frontend_ip_configuration {
    name                 = "${local.frontend_ip_configuration_name}_private"
    private_ip_address_allocation = "Static"
    private_ip_address   = "10.100.8.249"
    subnet_id     = data.azurerm_subnet.application_gateway_subnet.id
  }

  dynamic "backend_address_pool" {
    for_each = [for b in var.backend_apps : {
      name = "${b.name}-beap"
      ip_addresses = b.ip_addresses
    }]

    content {
      name  = backend_address_pool.value.name
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "backend_http_settings" {
    for_each = [for b in var.backend_apps : {
      name = "${b.name}-be-htst"
    }]

    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = "Disabled"
      affinity_cookie_name                = backend_http_settings.value.name
      path                                = ""
      port                                = 80
      protocol                            = "Http"
      request_timeout                     = 30
      probe_name                          = backend_http_settings.value.name
    }
  }

    dynamic "http_listener" {
    for_each = [for b in var.backend_apps : {
      name = "${b.name}-httplstn"
      fqdn = b.fqdn
    }]

    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}_private"
      frontend_port_name             = local.frontend_port_name
      protocol                       = "Http"
      #ssl_certificate_name           = "wildcard-hearings-reform-hmcts-net"
      host_name                      = http_listener.value.fqdn
    }
  }

  dynamic "request_routing_rule" {
    for_each = [for b in var.backend_apps : {
      name         = "${b.name}-rqrt"
      listener     = "${b.name}-httplstn"
      httpsettings = "${b.name}-be-htst"
      be_pool      = "${b.name}-beap"
      path_map     = "${b.name}-pathmap"
    }]

    content {
      name               = request_routing_rule.value.name
      rule_type          = "basic"
      http_listener_name = request_routing_rule.value.listener
      backend_address_pool_name  = request_routing_rule.value.be_pool
      backend_http_settings_name = request_routing_rule.value.httpsettings
    }
  }

  dynamic "probe" {
    for_each = [for b in var.backend_apps : {
      name         = "${b.name}-be-htst"
      listener     = "${b.name}-httplstn"
      httpsettings = "${b.name}-be-htst"
      be_pool      = "${b.name}-beap"
      fqdn          = b.fqdn
    }]

    content {
      interval                                  = 10
      minimum_servers                           = 0
      name                                      = probe.value.name
      path                                      = "/health/liveness"
      protocol                                  = "Http"
      timeout                                   = 15
      host                                      = probe.value.fqdn
      unhealthy_threshold                       = 3

      match {
        status_code = ["200-399"]
        body        = ""
      }
    }
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
}
