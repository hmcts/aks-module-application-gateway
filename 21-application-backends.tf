locals {

  frontend_port_name             = format("%s_application_gateway_%s_feport", var.network_shortname, var.deploy_environment)
  frontend_ip_configuration_name = format("%s_application_gateway_%s_feip", var.network_shortname, var.deploy_environment)
  

  backend_apps = [
    {
      name                          = "test1",
      ip_addresses                   = ["1.1.1.1", "2.2.2.2"],
      fqdn                          = "somedommain1.domain.com"
    },
    {
      name                          = "test2",
      ip_addresses                   = ["3.3.3.3", "4.4.4.4"]
      fqdn                          = "somedommain2.domain.com"
    },
    {
      name                          = "test3",
      ip_addresses                   = ["5.5.5.5", "6.6.6.6"]
      fqdn                          = "somedommain3.domain.com"
    }]

}