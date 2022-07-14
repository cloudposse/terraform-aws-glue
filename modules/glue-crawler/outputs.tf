output "id" {
  description = "Glue crawler ID"
  value       = local.enabled ? aws_glue_crawler.this[0].id : ""
}

output "name" {
  description = "Glue crawler name"
  value       = local.enabled ? aws_glue_crawler.this[0].name : ""
}

output "arn" {
  description = "Glue crawler ARN"
  value       = local.enabled ? aws_glue_crawler.this[0].arn : ""
}
