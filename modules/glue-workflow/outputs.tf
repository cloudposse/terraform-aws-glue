output "id" {
  description = "Glue workflow ID"
  value       = local.enabled ? aws_glue_workflow.this[0].id : ""
}

output "arn" {
  description = "Glue workflow ARN"
  value       = local.enabled ? aws_glue_workflow.this[0].arn : ""
}
