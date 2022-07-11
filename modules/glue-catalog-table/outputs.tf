output "id" {
  description = "Catalog table ID"
  value       = local.enabled ? aws_glue_catalog_table.this[0].id : ""
}

output "arn" {
  description = "Catalog table ARN"
  value       = local.enabled ? aws_glue_catalog_table.this[0].arn : ""
}
