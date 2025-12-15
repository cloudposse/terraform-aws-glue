locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler
resource "aws_glue_crawler" "this" {
  count = local.enabled ? 1 : 0

  name                   = coalesce(var.crawler_name, module.this.id)
  description            = var.crawler_description
  database_name          = var.database_name
  role                   = var.role
  schedule               = var.schedule
  classifiers            = var.classifiers
  configuration          = var.configuration
  security_configuration = var.security_configuration
  table_prefix           = var.table_prefix

  dynamic "catalog_target" {
    for_each = var.catalog_target != null ? var.catalog_target : []

    content {
      database_name = catalog_target.value.database_name
      tables        = catalog_target.value.tables
    }
  }

  dynamic "delta_target" {
    for_each = var.delta_target != null ? var.delta_target : []

    content {
      connection_name           = delta_target.value.connection_name
      create_native_delta_table = delta_target.value.create_native_delta_table
      delta_tables              = delta_target.value.delta_tables
      write_manifest            = delta_target.value.write_manifest
    }
  }

  dynamic "dynamodb_target" {
    for_each = var.dynamodb_target != null ? var.dynamodb_target : []

    content {
      path      = dynamodb_target.value.path
      scan_all  = try(dynamodb_target.value.scan_all, null)
      scan_rate = try(dynamodb_target.value.scan_rate, null)
    }
  }

  dynamic "jdbc_target" {
    for_each = var.jdbc_target != null ? var.jdbc_target : []

    content {
      connection_name = jdbc_target.value.connection_name
      path            = jdbc_target.value.path
      exclusions      = jdbc_target.value.exclusions
    }
  }

  dynamic "mongodb_target" {
    for_each = var.mongodb_target != null ? var.mongodb_target : []

    content {
      connection_name = mongodb_target.value.connection_name
      path            = mongodb_target.value.path
      scan_all        = try(mongodb_target.value.scan_all, null)
    }
  }

  dynamic "s3_target" {
    for_each = var.s3_target != null ? var.s3_target : []

    content {
      path                = s3_target.value.path
      connection_name     = try(s3_target.value.connection_name, null)
      exclusions          = try(s3_target.value.exclusions, null)
      sample_size         = try(s3_target.value.sample_size, null)
      event_queue_arn     = try(s3_target.value.event_queue_arn, null)
      dlq_event_queue_arn = try(s3_target.value.dlq_event_queue_arn, null)
    }
  }

  dynamic "lineage_configuration" {
    for_each = var.lineage_configuration != null ? [true] : []

    content {
      crawler_lineage_settings = var.lineage_configuration.crawler_lineage_settings
    }
  }

  dynamic "schema_change_policy" {
    for_each = var.schema_change_policy != null ? [true] : []

    content {
      delete_behavior = var.schema_change_policy.delete_behavior
      update_behavior = var.schema_change_policy.update_behavior
    }
  }

  dynamic "recrawl_policy" {
    for_each = var.recrawl_policy != null ? [true] : []

    content {
      recrawl_behavior = var.recrawl_policy.recrawl_behavior
    }
  }

  tags = module.this.tags
}
