output "id" {
  description = "ID of the provisioned glue connection"
  value       = local.enabled ? split(":", one(aws_glue_connection.this.*.id))[1] : null
}

output "arn" {
  description = "ARN of the provisioned glue connection"
  value       = local.enabled ? one(aws_glue_connection.this.*.arn) : null
}
