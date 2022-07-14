output "id" {
  description = "Glue workflow ID"
  value       = local.enabled ? aws_glue_workflow.this[0].id : ""
}

output "name" {
  description = "Glue workflow name"
  value       = local.enabled ? aws_glue_workflow.this[0].name : ""
}

output "arn" {
  description = "Glue workflow ARN"
  value       = local.enabled ? aws_glue_workflow.this[0].arn : ""
}
