output "workflow_id" {
  description = "ID of the provisioned glue workflow"
  value       = module.this.enabled ? module.aws_glue_workflow.this[0].id : null
}

output "job_id" {
  description = "ID of the provisioned glue job"
  value       = module.this.enabled ? module.aws_glue_job.this[0].id : null
}

output "workflow_arn" {
  description = "ARN of the provisioned glue workflow"
  value       = module.this.enabled ? module.aws_glue_workflow.this[0].arn : null
}

output "job_arn" {
  description = "ARN of the provisioned glue job"
  value       = module.this.enabled ? module.aws_glue_job.this[0].arn : null
}
