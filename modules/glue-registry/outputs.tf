output "id" {
  description = "Registry ID"
  value       = local.enabled ? aws_glue_registry.this[0].id : ""
}

output "arn" {
  description = "Registry ARN"
  value       = local.enabled ? aws_glue_registry.this[0].arn : ""
}
