locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table
resource "aws_glue_catalog_table" "this" {
  count = local.enabled ? 1 : 0

  name               = coalesce(var.catalog_table_name, module.this.id)
  description        = var.catalog_table_description
  database_name      = var.database_name
  catalog_id         = var.catalog_id
  owner              = var.owner
  parameters         = var.parameters
  retention          = var.retention
  table_type         = var.table_type
  view_expanded_text = var.view_expanded_text
  view_original_text = var.view_original_text

  dynamic "partition_index" {
    for_each = var.partition_index != null ? [true] : []

    content {
      index_name = var.partition_index.index_name
      keys       = var.partition_index.keys
    }
  }

  dynamic "partition_keys" {
    for_each = var.partition_keys != null ? [true] : []

    content {
      name    = var.partition_keys.name
      comment = try(var.partition_keys.comment, null)
      type    = try(var.partition_keys.type, null)
    }
  }

  dynamic "target_table" {
    for_each = var.target_table != null ? [true] : []

    content {
      catalog_id    = var.target_table.catalog_id
      database_name = var.target_table.database_name
      name          = var.target_table.name
    }
  }

  dynamic "storage_descriptor" {
    for_each = var.storage_descriptor != null ? [true] : []

    content {
      bucket_columns            = try(var.storage_descriptor.bucket_columns, null)
      compressed                = try(var.storage_descriptor.compressed, null)
      input_format              = try(var.storage_descriptor.input_format, null)
      location                  = try(var.storage_descriptor.location, null)
      number_of_buckets         = try(var.storage_descriptor.number_of_buckets, null)
      output_format             = try(var.storage_descriptor.output_format, null)
      parameters                = try(var.storage_descriptor.parameters, null)
      stored_as_sub_directories = try(var.storage_descriptor.stored_as_sub_directories, null)

      dynamic "columns" {
        for_each = try(var.storage_descriptor.columns, null) != null ? var.storage_descriptor.columns : []

        content {
          name       = columns.value.name
          comment    = try(columns.value.comment, null)
          parameters = try(columns.value.parameters, null)
          type       = try(columns.value.type, null)
        }
      }

      dynamic "schema_reference" {
        for_each = try(var.storage_descriptor.schema_reference, null) != null ? [true] : []

        content {
          schema_version_number = var.storage_descriptor.schema_reference.schema_version_number
          schema_version_id     = try(var.storage_descriptor.schema_reference.schema_version_id, null)

          dynamic "schema_id" {
            for_each = try(var.storage_descriptor.schema_reference.schema_id, null) != null ? [true] : []

            content {
              registry_name = try(var.storage_descriptor.schema_reference.schema_id.registry_name, null)
              schema_arn    = try(var.storage_descriptor.schema_reference.schema_id.schema_arn, null)
              schema_name   = try(var.storage_descriptor.schema_reference.schema_id.schema_name, null)
            }
          }
        }
      }

      dynamic "ser_de_info" {
        for_each = try(var.storage_descriptor.ser_de_info, null) != null ? [true] : []

        content {
          name                  = try(var.storage_descriptor.ser_de_info.name, null)
          parameters            = try(var.storage_descriptor.ser_de_info.parameters, null)
          serialization_library = try(var.storage_descriptor.ser_de_info.serialization_library, null)
        }
      }

      dynamic "skewed_info" {
        for_each = try(var.storage_descriptor.skewed_info, null) != null ? [true] : []

        content {
          skewed_column_names               = try(var.storage_descriptor.skewed_info.skewed_column_names, null)
          skewed_column_value_location_maps = try(var.storage_descriptor.skewed_info.skewed_column_value_location_maps, null)
          skewed_column_values              = try(var.storage_descriptor.skewed_info.skewed_column_values, null)
        }
      }

      dynamic "sort_columns" {
        for_each = try(var.storage_descriptor.sort_columns, null) != null ? [true] : []

        content {
          column     = var.storage_descriptor.sort_columns.column
          sort_order = var.storage_descriptor.sort_columns.sort_order
        }
      }
    }
  }
}
