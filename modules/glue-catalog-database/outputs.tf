output "id" {
  description = "Catalog database ID"
  value       = local.enabled ? aws_glue_catalog_database.this[0].id : ""
}

output "name" {
  description = "Catalog database name"
  value       = local.enabled ? aws_glue_catalog_database.this[0].name : ""
}

output "arn" {
  description = "Catalog database ARN"
  value       = local.enabled ? aws_glue_catalog_database.this[0].arn : ""
}
