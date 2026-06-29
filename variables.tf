# ============================================================
# variables.tf — Variables de configuración y credenciales
# IMPORTANTE: Usar variables de entorno o terraform.tfvars
# ============================================================

variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "azure_subscription_id" {
  description = "ID de suscripción de Azure"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "ID del tenant de Azure AD"
  type        = string
  sensitive   = true
}

variable "azure_location" {
  description = "Región de Azure para recursos de datos (SQL)"
  type        = string
  default     = "chilecentral"
}

variable "azure_resource_group_location" {
  description = "Región del Resource Group de Azure"
  type        = string
  default     = "eastus"
}

variable "azure_resource_group_name" {
  description = "Nombre del grupo de recursos de Azure"
  type        = string
}

variable "azure_sql_admin_login" {
  description = "Login del administrador de Azure SQL"
  type        = string
  sensitive   = true
}

variable "azure_sql_admin_password" {
  description = "Contraseña del administrador de Azure SQL"
  type        = string
  sensitive   = true
}

variable "gcp_project_id" {
  description = "ID del proyecto de Google Cloud"
  type        = string
  sensitive   = true
}

variable "gcp_region" {
  description = "Región de GCP"
  type        = string
  default     = "us-central1"
}

variable "gcp_credentials_file" {
  description = "Ruta al archivo de credenciales de cuenta de servicio GCP"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Nombre del proyecto para etiquetado de recursos"
  type        = string
  default     = "cloud-panel-infra"
}

variable "environment" {
  description = "Entorno de despliegue (dev, staging, prod)"
  type        = string
  default     = "prod"
}