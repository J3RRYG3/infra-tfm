# ============================================================
# outputs.tf — Metadatos de la arquitectura seleccionada
# Nota: los outputs de recursos específicos deben añadirse en
#       main.tf una vez que se conozcan los nombres de recursos.
# ============================================================

output "c_mputo_selected" {
  description = "Servicio seleccionado para la categoría Cómputo"
  value       = "GCP — Google Cloud Run (~$35.00/mes)"
}

output "almacenamiento_de_objetos_selected" {
  description = "Servicio seleccionado para la categoría Almacenamiento de Objetos"
  value       = "GCP — Google Cloud Storage Standard (~$10.00/mes)"
}

output "base_de_datos_selected" {
  description = "Servicio seleccionado para la categoría Base de Datos"
  value       = "Azure — Azure SQL Database Serverless (~$25.00/mes)"
}

output "gesti_n_de_identidad_selected" {
  description = "Servicio seleccionado para la categoría Gestión de Identidad"
  value       = "AWS — Amazon Cognito User Pools (~$5.00/mes)"
}

output "redes_y_entrega_de_contenido_selected" {
  description = "Servicio seleccionado para la categoría Redes y Entrega de Contenido"
  value       = "AWS — Amazon CloudFront (~$10.00/mes)"
}
