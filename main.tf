terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
}

variable "project_name" {
  description = "Nombre del proyecto para tags/labels."
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (e.g., dev, prod)."
  type        = string
}

variable "gcp_project_id" {
  description = "ID del proyecto de GCP."
  type        = string
}

variable "gcp_region" {
  description = "Región de GCP."
  type        = string
  default     = "us-central1"
}

variable "aws_region" {
  description = "Región de AWS."
  type        = string
  default     = "us-east-1"
}

variable "azure_resource_group_name" {
  description = "Nombre del grupo de recursos de Azure."
  type        = string
}

variable "azure_location" {
  description = "Ubicación de Azure."
  type        = string
  default     = "eastus"
}

variable "azure_sql_admin_login" {
  description = "Login del administrador de Azure SQL."
  type        = string
  sensitive   = true
}

variable "azure_sql_admin_password" {
  description = "Contraseña del administrador de Azure SQL."
  type        = string
  sensitive   = true
}

resource "google_cloud_run_v2_service" "main" {
  name     = "midrive-app-service"
  location = var.gcp_region
  project  = var.gcp_project_id

  template {
    containers {
      image = "gcr.io/cloudrun/hello" # Placeholder image, replace with actual application image
    }
    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  labels = {
    project     = var.project_name
    environment = var.environment
  }
}

resource "google_storage_bucket" "main" {
  name          = "midrive-user-files-${var.gcp_project_id}"
  location      = "US" # Multi-region for high availability, or specify a single region like var.gcp_region
  project       = var.gcp_project_id
  storage_class = "STANDARD"

  uniform_bucket_level_access = true

  labels = {
    project     = var.project_name
    environment = var.environment
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.azure_resource_group_name
  location = var.azure_location

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

resource "azurerm_mssql_server" "main" {
  name                         = "midrive-sql-server"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0" # SQL Server 2019
  administrator_login          = var.azure_sql_admin_login
  administrator_login_password = var.azure_sql_admin_password

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

resource "azurerm_mssql_database" "main" {
  name                        = "midrive-user-db"
  server_name                 = azurerm_mssql_server.main.name
  resource_group_name         = azurerm_resource_group.main.name
  sku_name                    = "Serverless"
  max_size_gb                 = 32
  min_capacity                = 0.5 # Minimum vCores for Serverless
  auto_pause_delay_in_minutes = 60

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

resource "aws_cognito_user_pool" "main" {
  name = "midrive-user-pool"

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = trimprefix(google_cloud_run_v2_service.main.uri, "https://") # Cloud Run service URL as origin
    origin_id   = "CloudRunOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for miDrive application"
  default_root_object = "index.html" # Assuming a web app

  default_cache_behavior {
    target_origin_id       = "CloudRunOrigin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}