output "id" {
  description = "Glue schema ID"
  value       = local.enabled ? aws_glue_schema.this[0].id : ""
}

output "name" {
  description = "Glue schema name"
  value       = local.enabled ? aws_glue_schema.this[0].schema_name : ""
}

output "arn" {
  description = "Glue schema ARN"
  value       = local.enabled ? aws_glue_schema.this[0].arn : ""
}

output "registry_name" {
  description = "Glue registry name"
  value       = local.enabled ? aws_glue_schema.this[0].registry_name : ""
}

output "latest_schema_version" {
  description = "The latest version of the schema associated with the returned schema definition"
  value       = local.enabled ? aws_glue_schema.this[0].latest_schema_version : ""
}

output "next_schema_version" {
  description = "The next version of the schema associated with the returned schema definition"
  value       = local.enabled ? aws_glue_schema.this[0].next_schema_version : ""
}

output "schema_checkpoint" {
  description = "The version number of the checkpoint (the last time the compatibility mode was changed)"
  value       = local.enabled ? aws_glue_schema.this[0].schema_checkpoint : ""
}
