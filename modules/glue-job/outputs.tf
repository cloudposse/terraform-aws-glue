output "id" {
  description = "Glue job ID"
  value       = local.enabled ? aws_glue_job.this[0].id : null
}

output "arn" {
  description = "Glue job ARN"
  value       = local.enabled ? aws_glue_job.this[0].arn : null
}
