# Infraestructura Multicloud — Cloud Panel

## Resumen del Proyecto
miDrive es una plataforma web de almacenamiento de archivos personales que aloja un aplicativo monolítico ligero en un contenedor Docker. La arquitectura propuesta es multicloud, distribuyendo el cómputo, base de datos e identidad en AWS, y el almacenamiento de objetos principal en GCP, para optimizar costos operativos y de salida de datos, cumpliendo con las directrices FinOps de pago por uso y escalado a cero.

## Arquitectura Seleccionada
- **Cómputo**: GCP — Google Cloud Run (~$35.00/mes)
- **Almacenamiento de Objetos**: GCP — Google Cloud Storage Standard (~$10.00/mes)
- **Base de Datos**: Azure — Azure SQL Database Serverless (~$25.00/mes)
- **Gestión de Identidad**: AWS — Amazon Cognito User Pools (~$5.00/mes)
- **Redes y Entrega de Contenido**: AWS — Amazon CloudFront (~$10.00/mes)

**Costo Total Estimado: ~$85.00 USD/mes**

---

## Prerrequisitos
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- Credenciales de los proveedores cloud seleccionados

## Configuración de Credenciales

### Opción A: Variables de Entorno (Recomendado)
```bash
# AWS
export TF_VAR_aws_access_key="tu-access-key"
export TF_VAR_aws_secret_key="tu-secret-key"

# Azure
export TF_VAR_azure_subscription_id="tu-subscription-id"
export TF_VAR_azure_tenant_id="tu-tenant-id"

Terraform para Azure usa autenticacion por Azure CLI en este proyecto.
Ejecuta `az login` antes de `terraform plan/apply`.

# GCP
export TF_VAR_gcp_project_id="tu-project-id"
export TF_VAR_gcp_credentials_file="/ruta/a/credenciales.json"
```

### Opción B: Archivo terraform.tfvars
Crea un archivo `terraform.tfvars` (NO lo subas a control de versiones):
```hcl
aws_access_key = "tu-access-key"
# ... resto de variables
```

## Comandos de Despliegue

```bash
# 1. Inicializar Terraform (descarga providers)
terraform init

# 2. Revisar el plan de cambios
terraform plan

# 3. Aplicar la infraestructura
terraform apply

# 4. Para destruir la infraestructura
terraform destroy
```

---
*Generado por [Cloud Panel](https://github.com/j3rryg3/cloudPanel) — 2026-06-27*
