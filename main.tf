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
  location = var.azure_resource_group_location

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

resource "azurerm_mssql_server" "main" {
  name                         = "midrive-sql-server"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = var.azure_location
  version                      = "12.0" # SQL Server 2019
  administrator_login          = var.azure_sql_admin_login
  administrator_login_password = var.azure_sql_admin_password

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

resource "azurerm_mssql_firewall_rule" "allow_all_ipv4" {
  name             = "allow-all-ipv4-poc"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_mssql_database" "main" {
  name                        = "midrive-user-db"
  server_id                   = azurerm_mssql_server.main.id
  sku_name                    = "GP_S_Gen5_1"
  max_size_gb                 = 32
  min_capacity                = 0.5 # Minimum vCores for Serverless
  auto_pause_delay_in_minutes = 60
  storage_account_type        = "Local"
  geo_backup_enabled          = true

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

resource "aws_cognito_user_pool_client" "main" {
  name         = "midrive-app-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret                      = false
  prevent_user_existence_errors        = "ENABLED"
  allowed_oauth_flows_user_pool_client = false
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
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