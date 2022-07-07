output "id" {
  description = "Trigger ID"
  value       = local.enabled ? aws_glue_trigger.this[0].id : ""
}

output "arn" {
  description = "Trigger ARN"
  value       = local.enabled ? aws_glue_trigger.this[0].arn : ""
}
