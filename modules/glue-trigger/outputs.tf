output "id" {
  description = "Workflow name"
  value       = module.this.enabled ? aws_glue_trigger.this.id : null
}

output "arn" {
  description = "Amazon Resource Name (ARN) of Glue Workflow"
  value       = module.this.enabled ? aws_glue_trigger.this.arn : null
}
