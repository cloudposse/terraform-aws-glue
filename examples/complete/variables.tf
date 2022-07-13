variable "region" {
  type        = string
  description = "AWS Region"
}

variable "glue_version" {
  description = "The version of glue to use"
  type        = string
  default     = "2.0"
}
