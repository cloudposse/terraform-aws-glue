variable "actions" {
  description = "Arguments to be passed to the job action script."
  type = list(object({
    job_name     = string,
    crawler_name = string,
    arguments    = map(string),
    timeout      = number
  }))
}

variable "conditions" {
  description = "Conditions for activating this trigger. Required for triggers where type is CONDITIONAL"
  type        = list(map(string))
  default     = []
}

variable "logical" {
  description = "How to handle multiple conditions. Defaults to AND. Valid values are AND or ANY."
  type        = string
  default     = "AND"

  validation {
    condition     = contains(["AND", "ANY"], var.logical)
    error_message = "Supported values are AND and ANY."
  }
}

variable "max_concurrent_runs" {
  description = "The maximum number of concurrent runs allowed for a job. The default is 1."
  type        = number
  default     = 1
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "schedule" {
  description = "Cron formatted schedule. Required for triggers with type SCHEDULED."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("/(((\\d+,)+\\d+|(\\d+(\\/|-)\\d+)|\\d+|\\*) ?){5,7}/", var.schedule))
    error_message = "The value must be a valid cron expression."
  }
}

variable "type" {
  description = "The type of workflow. Options are CONDITIONAL or SCHEDULED."
  type        = string
  default     = "CONDITIONAL"

  validation {
    condition     = contains(["CONDITIONAL", "SCHEDULE"], var.type)
    error_message = "Supported options are CONDITIONAL or SCHEDULED."
  }
}

variable "workflow_name" {
  description = "Name of the Glue workflow to be related to."
  type        = string
  default     = ""
}
