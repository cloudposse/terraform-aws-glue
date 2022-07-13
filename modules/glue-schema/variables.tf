variable "schema_name" {
  type        = string
  description = "Glue schema name. If not provided, the name will be generated from the context."
  default     = null
}

variable "schema_description" {
  type        = string
  description = "Glue schema description."
  default     = null
}

variable "registry_arn" {
  type        = string
  description = "The ARN of the Glue Registry to create the schema in."
}

variable "data_format" {
  type        = string
  description = "The data format of the schema definition. Valid values are `AVRO`, `JSON` and `PROTOBUF`."
  default     = "JSON"

  validation {
    condition     = contains(["AVRO", "JSON", "PROTOBUF"], var.data_format)
    error_message = "Supported options are AVRO, JSON or PROTOBUF."
  }
}

variable "compatibility" {
  type        = string
  description = "The compatibility mode of the schema. Valid values are NONE, DISABLED, BACKWARD, BACKWARD_ALL, FORWARD, FORWARD_ALL, FULL, and FULL_ALL."
  default     = "NONE"

  validation {
    condition     = contains(["NONE", "DISABLED", "BACKWARD", "BACKWARD_ALL", "FORWARD", "FORWARD_ALL", "FULL", "FULL_ALL"], var.compatibility)
    error_message = "Supported options are NONE, DISABLED, BACKWARD, BACKWARD_ALL, FORWARD, FORWARD_ALL, FULL, and FULL_ALL."
  }
}

variable "schema_definition" {
  type        = string
  description = "The schema definition using the `data_format` setting."
  default     = null
}
