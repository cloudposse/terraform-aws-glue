output "id" {
  description = "Crawler ID"
  value       = local.enabled ? aws_glue_crawler.this[0].id : ""
}

output "arn" {
  description = "Crawler ARN"
  value       = local.enabled ? aws_glue_crawler.this[0].arn : ""
}
