output "id" {
  description = "Glue trigger ID"
  value       = local.enabled ? aws_glue_trigger.this[0].id : ""
}

output "name" {
  description = "Glue trigger name"
  value       = local.enabled ? aws_glue_trigger.this[0].name : ""
}

output "arn" {
  description = "Glue trigger ARN"
  value       = local.enabled ? aws_glue_trigger.this[0].arn : ""
}
