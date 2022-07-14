output "id" {
  description = "Glue connection ID"
  value       = local.enabled ? aws_glue_connection.this[0].id : ""
}

output "name" {
  description = "Glue connection name"
  value       = local.enabled ? aws_glue_connection.this[0].name : ""
}

output "arn" {
  description = "Glue connection ARN"
  value       = local.enabled ? aws_glue_connection.this[0].arn : ""
}
