output "catalog_database_id" {
  description = "Catalog database ID"
  value       = module.glue_catalog_database.id
}

output "catalog_database_name" {
  description = "Catalog database name"
  value       = module.glue_catalog_database.name
}

output "catalog_database_arn" {
  description = "Catalog database ARN"
  value       = module.glue_catalog_database.arn
}

output "catalog_table_id" {
  description = "Catalog table ID"
  value       = module.glue_catalog_table.id
}

output "catalog_table_name" {
  description = "Catalog table name"
  value       = module.glue_catalog_table.name
}

output "catalog_table_arn" {
  description = "Catalog table ARN"
  value       = module.glue_catalog_table.arn
}

output "crawler_id" {
  description = "Crawler ID"
  value       = module.glue_crawler.id
}

output "crawler_arn" {
  description = "Crawler ARN"
  value       = module.glue_crawler.arn
}
