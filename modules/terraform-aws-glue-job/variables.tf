variable "auto_scaling_enabled" {
  description = "Should autoscaling arguments be passed to glue jobs at execution time?"
  type        = bool
  default     = false
}

variable "connections" {
  description = "The list of connections used for this job."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue(
      [for connection in var.connections : connection != ""]
    )
    error_message = "All connections should be valid strings."
  }
}

variable "extra_py_files" {
  description = "Libraries/wheel dependencies added to the glue job at run time."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue(
      [for py_file in var.extra_py_files : anytrue([can(regex("^.*\\.whl$$", py_file)), can(regex("^.*\\.py$$", py_file))])]
    )
    error_message = "Must contain valid python files ending with either .whl or .py."
  }
}

variable "extra_files" {
  description = "Libraries/wheel dependencies added to the glue job at run time."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue(
      [for file in var.extra_files : can(regex("^s3://([^/]+)/(.*?([^/]+)/.+)$", file))]
    )
    error_message = "Must contain valid S3 URIs."
  }
}

variable "glue_datacatalog_enabled" {
  description = "Should arguments that allow access to the glue datacatalog for jobs be enabled be used?"
  type        = bool
  default     = false
}

variable "role_arn" {
  description = "The glue service role arn that ETL Job assumes. Needs access to the S3 datalake"
  type        = string
  default     = ""

  validation {
    condition     = var.role_arn == "" || can(regex("^arn:aws:iam::[[:digit:]]{12}:role/.+", var.role_arn))
    error_message = "Must be a valid AWS IAM role ARN."
  }
}

variable "glue_version" {
  description = "The version of glue to use"
  type        = string
  default     = "2.0"

  validation {
    condition     = contains(["1.0", "2.0"], var.glue_version)
    error_message = "1.0 and 2.0 are the only acceptable glue versions."
  }
}

variable "default_arguments" {
  description = "default arguments for the job"
  type        = map(string)
  default     = {}
}

variable "job_bookmark_option" {
  description = <<-EOT
  Controls the behavior of a job bookmark. The following option values can be set.

 ‑‑job‑bookmark‑option Value|Description|
  ---|---|
  job-bookmark-enable|Keep track of previously processed data. When a job runs, process new data since the last checkpoint.|
  job-bookmark-disable|Always process the entire dataset. You are responsible for managing the output from previous job runs.|
  job-bookmark-pause|Process incremental data since the last successful run or the data in the range identified by the following suboptions, without updating the state of the last bookmark. You are responsible for managing the output from previous job runs. The two suboptions are as follows:|
  job-bookmark-from|<from-value> is the run ID that represents all the input that was processed until the last successful run before and including the specified run ID. The corresponding input is ignored.|
  job-bookmark-to |<to-value> is the run ID that represents all the input that was processed until the last successful run before and including the specified run ID. The corresponding input excluding the input identified by the <from-value> is processed by the job. Any input later than this input is also excluded for processing.|

  The job bookmark state is not updated when this option set is specified.

  The suboptions are optional. However, when used, both suboptions must be provided.
  EOT
  type        = string
  default     = ""

  validation {
    condition     = var.job_bookmark_option == "" || contains(["job-bookmark-enable", "job-bookmark-disable"], var.job_bookmark_option)
    error_message = "Value for `job_bookmark_option` must be one of job-bookmark-enable or job-bookmark-disable."
  }
}

variable "logging_enabled" {
  description = "Flag to set cloudwatch metrics be captured for the Glue job."
  type        = bool
  default     = true
}

variable "cloudwatch_logs_retention_in_days" {
  description = <<-EOT
  Number of days you want to retain log events in the log group.

  Must be one of: [0 1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653]

  Ignored if `var.cloudwatch_logs_enabled` is set to `false`.
  EOT
  default     = "90"

  validation {
    condition     = contains(["0", "1", "3", "5", "7", "14", "30", "60", "90", "120", "150", "180", "365", "400", "545", "731", "1827", "3653"], var.cloudwatch_logs_retention_in_days)
    error_message = "Must be one of: [0 1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653]."
  }
}

variable "max_concurrent_runs" {
  description = "The maximum number of concurrent runs allowed for a job. The default is 1"
  type        = number
  default     = -1
}

variable "max_retries" {
  description = "The maximum number of times to retry this job if it fails"
  type        = number
  default     = 1
}

variable "metrics_enabled" {
  description = "Flag to set cloudwatch metrics be captured for the Glue job."
  type        = bool
  default     = false
}

variable "number_of_workers" {
  description = "The number of workers of a defined workerType that are allocated when a job runs."
  type        = number
  default     = 2
}

variable "optimal_partition_size" {
  description = <<-EOT
  Optimal partition sizing of your data sets. Defaults to 512mb. Required to use Compaction ETL script that is 
  managed by this module.
  EOT
  type        = number
  default     = 512
}

variable "python_version" {
  description = <<-EOT
  Version of python supported by this glue job.
  EOT
  type        = string
  default     = "3"

  validation {
    condition     = contains(["2", "3"], var.python_version)
    error_message = "Python version must either be 2 or 3."
  }
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "rename_algorithm_v2_enabled" {
  description = "Sets the EMRFS rename algorithm version to version 2. When a Spark job uses dynamic partition overwrite mode, there is a possibility that a duplicate partition is created. For instance, you can end up with a duplicate partition such as s3://bucket/table/location/p1=1/p1=1. Here, P1 is the partition that is being overwritten. Rename algorithm version 2 fixes this issue."
  type        = bool
  default     = false
}

variable "script_s3_key" {
  description = "Script location for generating script from parameters."
  type        = string

  validation {
    condition     = can(regex("^s3://([^/]+)/(.*?([^/]+)/.+)$", var.script_s3_key))
    error_message = "S3 Script key must match valid S3 URI."
  }
}

variable "s3_parquet_optimized_committer_enabled" {
  description = "Should glue jobs be notified to use s3 parquet optimized committer?"
  type        = bool
  default     = false
}


variable "security_configuration" {
  description = <<-EOT
  The name of the Security Configuration to be associated with the job.
  EOT
  type        = string
  default     = ""
}

variable "spark_ui_enabled" {
  description = <<-EOT
  Use Spark interface for monitoring glue jobs.
  EOT
  type        = bool
  default     = false
}

variable "spark_event_logs_path" {
  description = "Specifies an Amazon S3 path. When using the Spark UI monitoring feature, AWS Glue flushes the Spark event logs to this Amazon S3 path every 30 seconds to a bucket that can be used as a temporary directory for storing Spark UI events."
  type        = string
  default     = ""

  validation {
    condition     = var.spark_event_logs_path == "" || can(regex("^s3://([^/]+)/(.*?([^/]+)/.+)$", var.spark_event_logs_path))
    error_message = "Log path must match valid S3 URI."
  }
}

variable "tempdir" {
  description = "Specifies an Amazon S3 path to a bucket that can be used as a temporary directory for the job."
  type        = string
  default     = ""
  validation {
    condition     = var.tempdir == "" || can(regex("^s3://([^/]+)/(.*?([^/]+)/.+)$", var.tempdir))
    error_message = "Tempdir must match valid S3 URI."
  }
}

variable "timeout" {
  description = "The job timeout in minutes. The default is 2880 minutes (48 hours)."
  type        = number
  default     = 2880
}

variable "worker_type" {
  description = "The type of predefined worker that is allocated when a job runs. Accepts a value of Standard, G.1X, or G.2X"
  type        = string
  default     = "G.1X"

  validation {
    condition     = contains(["G.1X", "G.2X"], var.worker_type)
    error_message = "G.1X and G.2X are the only valid worker types."
  }
}
