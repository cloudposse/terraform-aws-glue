output "id" {
  description = "Glue catalog table ID"
  value       = local.enabled ? aws_glue_catalog_table.this[0].id : ""
}

output "name" {
  description = "Glue catalog table name"
  value       = local.enabled ? aws_glue_catalog_table.this[0].name : ""
}

output "arn" {
  description = "Glue catalog table ARN"
  value       = local.enabled ? aws_glue_catalog_table.this[0].arn : ""
}
