variable "region" {
  type        = string
  description = "AWS Region"
}

variable "glue_version" {
  type        = string
  description = "The version of glue to use"
  default     = "2.0"
}

variable "glue_catalog_table_partition_keys" {
  type        = map(any)
  description = "Configuration block of columns by which the table is partitioned. Only primitive types are supported as partition keys."
  default     = {}
}


variable "glue_catalog_table_partition_indices" {
  type = map(object({
    index_name = string
    keys       = list(string)
  }))
  description = "Configuration block for a maximum of 3 partition indexes."
  default     = {}
}
