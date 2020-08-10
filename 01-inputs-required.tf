variable "resource_group_name" {}
variable "deploy_environment" {}
variable "application_gateway_subnet_cidr_blocks" {}

variable "network_name" {}
variable "network_shortname" {}
variable "location" {}

variable "tag_project_name" {}
variable "tag_service" {}
variable "tag_environment" {}
variable "tag_cost_center" {}
variable "tag_app_operations_owner" {}
variable "tag_system_owner" {}
variable "tag_budget_owner" {}
variable "backend_apps" {
    type = list
}
