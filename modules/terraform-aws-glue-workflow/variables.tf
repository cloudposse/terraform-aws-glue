variable "default_run_properties" {
  description = "A map of default run properties for this workflow. These properties are passed to all jobs associated to the workflow."
  type        = map(string)
  default     = {}
}

variable "max_concurrent_runs" {
  description = "The maximum number of concurrent runs allowed for a job. The default is 1"
  type        = number
  default     = 1
}

variable "region" {
  type        = string
  description = "AWS Region"
}
