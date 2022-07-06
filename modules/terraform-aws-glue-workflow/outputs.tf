output "id" {
  description = "ID of the provisioned glue workflow"
  value       = module.this.enabled ? aws_glue_workflow.this[0].id : null
}

output "arn" {
  description = "ARN of the provisioned glue workflow"
  value       = module.this.enabled ? aws_glue_workflow.this[0].arn : null
}
