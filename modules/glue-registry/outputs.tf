output "id" {
  description = "Glue registry ID"
  value       = local.enabled ? aws_glue_registry.this[0].id : ""
}

output "name" {
  description = "Glue registry name"
  value       = local.enabled ? aws_glue_registry.this[0].registry_name : ""
}

output "arn" {
  description = "Glue registry ARN"
  value       = local.enabled ? aws_glue_registry.this[0].arn : ""
}
