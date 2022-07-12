output "id" {
  description = "Glue connection ID"
  value       = local.enabled ? split(":", one(aws_glue_connection.this.*.id))[1] : null
}

output "arn" {
  description = "Glue connection ARN"
  value       = local.enabled ? one(aws_glue_connection.this.*.arn) : null
}
