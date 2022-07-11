variable "crawler_name" {
  type        = string
  description = "Glue crawler name. If not provided, the name will be constructed from the context."
  default     = null
}

variable "crawler_description" {
  type        = string
  description = "Glue crawler description."
  default     = null
}

variable "database_name" {
  type        = string
  description = "Glue database where results are written."
  default     = null
}

variable "role" {
  type        = string
  description = "The IAM role friendly name (including path without leading slash), or ARN of an IAM role, used by the crawler to access other resources."
  default     = null
}
