# Cambios realizados sobre la configuracion inicial de Terraform

Fecha: 2026-06-29
Proyecto: infra-tfm

## 1) Cambios estructurales en Terraform

### Problema original
La configuracion tenia bloques duplicados de:
- terraform required_providers
- provider aws, azurerm y google
- variables repetidas

Esto provocaba errores en terraform init por definiciones duplicadas.

### Ajuste aplicado
- Se dejo una sola fuente de verdad para providers en providers.tf.
- Se dejo una sola fuente de verdad para variables en variables.tf.
- main.tf quedo enfocado en recursos.

Beneficio:
- terraform init y terraform plan pasan sin conflictos de duplicados.

## 2) Autenticacion de Azure sin client_id y client_secret

### Problema original
Con Azure for Students no siempre hay permisos para crear App Registration o Client Secret en Entra.

### Ajuste aplicado
- Se elimino dependencia de azure_client_id y azure_client_secret.
- Se configuro autenticacion via Azure CLI en provider azurerm.

Adicional:
- Se activo skip_provider_registration en azurerm para evitar bloqueos por auto registro de providers en suscripciones con permisos limitados.

Beneficio:
- Permite ejecutar Terraform con az login sin depender de secretos de Entra.

## 3) Ajustes del recurso Azure SQL Database al provider actual

### Problema original
El recurso de base de datos tenia argumentos antiguos.

### Ajustes aplicados
- Cambio de server_name y resource_group_name por server_id.
- Cambio de sku_name a un valor valido: GP_S_Gen5_1.

Beneficio:
- Compatibilidad con hashicorp azurerm 3.x.

## 4) Ajuste por politica regional de Azure

### Problema original
La suscripcion tiene policy de regiones permitidas.
Lista detectada:
- chilecentral
- northcentralus
- canadacentral
- mexicocentral
- brazilsouth

eastus no estaba permitido para algunos recursos.

### Ajustes aplicados
- Se separo la region del Resource Group de la region de SQL.
- Nueva variable: azure_resource_group_location.
- Se mantuvo Resource Group en eastus (ya existente).
- Se movio SQL a chilecentral (region permitida).

Beneficio:
- Evita reemplazar el Resource Group y cumple policy de regiones.

## 5) Ajuste por limitacion de geo redundancia en region

### Problema original
Error ProvisioningDisabled al crear la base SQL por geo redundancia no disponible en la region.

### Ajustes aplicados en azurerm_mssql_database
- storage_account_type = Local
- geo_backup_enabled = true

Nota:
- Durante validacion final, Azure SQL reporto persistentemente geo_backup_enabled = true.
- Se alineo Terraform a ese valor para evitar drift continuo en terraform plan.

Beneficio:
- Permite aprovisionar la base SQL en la region seleccionada.

## 6) Requisitos de GCP detectados durante el despliegue

### Bloqueos encontrados
- Billing deshabilitado.
- Cloud Run Admin API deshabilitada.
- Falta de permisos IAM para la service account usada por Terraform.

### Requisitos minimos para este proyecto
Service account en uso:
- unir-exercise@unir-481719.iam.gserviceaccount.com

Roles necesarios:
- roles/run.admin
- roles/storage.admin
- roles/iam.serviceAccountUser

Beneficio:
- Habilita creacion de Cloud Run y GCS bucket.

## 7) Tiempo de despliegue esperado

Observacion:
- CloudFront puede tardar alrededor de 10 a 15 minutos en crear distribucion.

Recomendacion:
- Considerar ese tiempo como normal para no cancelar apply antes de tiempo.

## 8) Recomendaciones para automatizar la proxima ejecucion

## Preflight recomendado (antes de terraform apply)
1. Confirmar Azure CLI disponible en PATH.
2. Ejecutar az login.
3. Verificar provider Microsoft.Sql en estado Registered.
4. Confirmar Billing activo en GCP.
5. Confirmar Cloud Run Admin API habilitada.
6. Confirmar IAM roles de la service account de Terraform.
7. Ejecutar terraform init, terraform plan, terraform apply.

## Variables recomendadas
Mantener separadas:
- azure_resource_group_location para el Resource Group
- azure_location para recursos de datos (SQL)

## Archivos de entrada
- terraform.tfvars como fuente principal de valores.
- .env como referencia local de trabajo, sin commitear secretos.

## 9) Resultado final de esta sesion

Se completo el despliegue multicloud con los ajustes anteriores y quedo estabilizada la configuracion para siguientes ejecuciones.

## 10) Ajuste adicional: Cognito App Client faltante

### Problema detectado
El proyecto consumidor (mi-drive) requiere AWS_COGNITO_CLIENT_ID en su .env.
La infraestructura inicial solo creaba el User Pool, pero no el App Client.

### Ajuste aplicado
- Se agrego aws_cognito_user_pool_client.main en main.tf.
- Se aprovisiono el recurso y se obtuvo el client_id.
- Se actualizo el .env de mi-drive con AWS_COGNITO_CLIENT_ID.

Beneficio:
- La aplicacion ya puede autenticar contra Cognito con User Pool + App Client.

## 11) Leccion operativa: uso de -target

### Situacion
Para crear rapido el Cognito App Client se uso terraform apply con -target.

### Recomendacion
Despues de cualquier despliegue con -target, ejecutar siempre:
1. terraform plan
2. terraform apply (si hay drift o cambios pendientes)

En esta sesion, ese paso detecto un ajuste pendiente en Azure SQL (geo_backup_enabled) y se aplico para dejar estado consistente.
