output "id" {
  description = "Catalog database ID"
  value       = local.enabled ? aws_glue_catalog_database.this[0].id : ""
}

output "arn" {
  description = "Catalog database ARN"
  value       = local.enabled ? aws_glue_catalog_database.this[0].arn : ""
}
