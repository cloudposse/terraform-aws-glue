output "id" {
  description = "Glue catalog database ID"
  value       = local.enabled ? aws_glue_catalog_database.this[0].id : ""
}

output "name" {
  description = "Glue catalog database name"
  value       = local.enabled ? aws_glue_catalog_database.this[0].name : ""
}

output "arn" {
  description = "Glue catalog database ARN"
  value       = local.enabled ? aws_glue_catalog_database.this[0].arn : ""
}
