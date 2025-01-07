# Azure Variables

variable "client_secret" {
  description = "Client Secret"
}

variable "client_id" {
  description = "Client ID"
}

variable "tenant_id" {
  description = "Tenant ID"
}

variable "subscription_id" {
  description = "Subscription ID"
}

# AWS Variables

variable "access_key" {
}

variable "secret_key" {
}

variable "region" {
  default = "us-west-1"
}
