output "workflow_id" {
  description = "Glue workflow ID"
  value       = module.glue_workflow.id
}

output "workflow_name" {
  description = "Glue workflow name"
  value       = module.glue_workflow.name
}

output "workflow_arn" {
  description = "Glue workflow ARN"
  value       = module.glue_workflow.arn
}

output "job_id" {
  description = "Glue job ID"
  value       = module.glue_job.id
}

output "job_name" {
  description = "Glue job name"
  value       = module.glue_job.name
}

output "job_arn" {
  description = "Glue job ARN"
  value       = module.glue_job.arn
}

output "trigger_id" {
  description = "Glue trigger ID"
  value       = module.glue_trigger.id
}

output "trigger_name" {
  description = "Glue trigger name"
  value       = module.glue_trigger.name
}

output "trigger_arn" {
  description = "Glue trigger ARN"
  value       = module.glue_trigger.arn
}
