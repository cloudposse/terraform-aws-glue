output "id" {
  description = "ID of the provisioned glue job"
  value       = module.this.enabled ? aws_glue_job.this[0].id : null
}

output "arn" {
  description = "ARN of the provisioned glue job"
  value       = module.this.enabled ? aws_glue_job.this[0].arn : null
}

output "log_group_name" {
  description = "Name of the log group created for the glue job"
  value       = module.this.enabled ? module.cloudwatch_log_group.log_group_name : null
}