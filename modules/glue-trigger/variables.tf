variable "region" {
  type        = string
  description = "AWS Region"
}

variable "actions" {
  type = list(object({
    job_name     = string,
    crawler_name = string,
    arguments    = map(string),
    timeout      = number
  }))
  description = "Arguments to be passed to the job action script."
}

variable "conditions" {
  type        = list(map(string))
  description = "Conditions for activating this trigger. Required for triggers where type is CONDITIONAL"
  default     = []
}

variable "logical" {
  type        = string
  description = "How to handle multiple conditions. Defaults to AND. Valid values are AND or ANY."
  default     = "AND"

  validation {
    condition     = contains(["AND", "ANY"], var.logical)
    error_message = "Supported values are AND and ANY."
  }
}

variable "max_concurrent_runs" {
  type        = number
  description = "The maximum number of concurrent runs allowed for a job. The default is 1."
  default     = 1
}

variable "schedule" {
  type        = string
  description = "Cron formatted schedule. Required for triggers with type SCHEDULED."
  default     = ""

  validation {
    condition     = can(regex("/(((\\d+,)+\\d+|(\\d+(\\/|-)\\d+)|\\d+|\\*) ?){5,7}/", var.schedule))
    error_message = "The value must be a valid cron expression."
  }
}

variable "type" {
  type        = string
  description = "The type of workflow. Options are CONDITIONAL or SCHEDULED."
  default     = "CONDITIONAL"

  validation {
    condition     = contains(["CONDITIONAL", "SCHEDULE", "ON_DEMAND"], var.type)
    error_message = "Supported options are CONDITIONAL, SCHEDULED or ON_DEMAND."
  }
}

variable "workflow_name" {
  type        = string
  description = "Name of the Glue workflow to be related to."
  default     = ""
}

variable "start_trigger" {
  type        = bool
  description = "Whether to start the created trigger"
  default     = true
}
