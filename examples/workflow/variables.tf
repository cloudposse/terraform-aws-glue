variable "region" {
  type        = string
  description = "AWS Region"
}

variable "glue_version" {
  type        = string
  description = "The version of glue to use"
  default     = "2.0"
}
