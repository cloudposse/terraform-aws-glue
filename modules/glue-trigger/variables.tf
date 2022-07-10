variable "region" {
  type        = string
  description = "AWS Region"
}

variable "trigger_name" {
  type        = string
  description = "Glue trigger name. If not provided, the name will be constructed from the context."
  default     = null
}

variable "trigger_description" {
  type        = string
  description = "Glue trigger description."
  default     = null
}

variable "workflow_name" {
  type        = string
  description = "A workflow to which the trigger should be associated to."
  default     = null
}

variable "actions" {
  type = list(object({
    job_name               = string
    crawler_name           = string
    arguments              = list(string)
    security_configuration = string
    notification_property  = map(string)
    timeout                = number
  }))
  description = "List of actions initiated by the trigger when it fires."
}

variable "conditions" {
  type = list(object({
    job_name         = string
    crawler_name     = string
    state            = string
    crawl_state      = string
    logical_operator = string
  }))
  description = "Conditions for activating the trigger. Required for triggers where type is `CONDITIONAL`."
  default     = []
}

variable "logical" {
  type        = string
  description = "How to handle multiple conditions. Defaults to `AND`. Valid values are `AND` or `ANY`."
  default     = "AND"

  validation {
    condition     = contains(["AND", "ANY"], var.logical)
    error_message = "Supported values are AND and ANY."
  }
}

variable "schedule" {
  type        = string
  description = "Cron formatted schedule. Required for triggers with type `SCHEDULED`."
  default     = null

  validation {
    condition     = can(regex("/(((\\d+,)+\\d+|(\\d+(\\/|-)\\d+)|\\d+|\\*) ?){5,7}/", var.schedule))
    error_message = "The value must be a valid Cron expression."
  }
}

variable "type" {
  type        = string
  description = "The type of trigger. Options are CONDITIONAL, SCHEDULED or ON_DEMAND."
  default     = "CONDITIONAL"

  validation {
    condition     = contains(["CONDITIONAL", "SCHEDULE", "ON_DEMAND"], var.type)
    error_message = "Supported options are CONDITIONAL, SCHEDULED or ON_DEMAND."
  }
}

variable "trigger_enabled" {
  type        = bool
  description = "Whether to start the created trigger."
  default     = true
}

variable "start_on_creation" {
  type        = bool
  description = "Set to `true` to start `SCHEDULED` and `CONDITIONAL` triggers when created. `true` is not supported for `ON_DEMAND` triggers."
  default     = true
}
