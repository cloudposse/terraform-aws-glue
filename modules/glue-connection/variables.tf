variable "connection_name" {
  type        = string
  description = "Connection name. If not provided, the name will be constructed from the context."
  default     = null
}

variable "connection_description" {
  type        = string
  description = "Connection description."
  default     = null
}

variable "catalog_id" {
  type        = string
  description = "The ID of the Data Catalog in which to create the connection. If none is supplied, the AWS account ID is used by default."
  default     = null
}

variable "connection_type" {
  description = "The type of the connection. Supported are: JDBC, MONGODB, KAFKA, and NETWORK. Defaults to JBDC"
  type        = string

  validation {
    condition     = contains(["JDBC", "MONGODB", "KAFKA", "NETWORK"], var.connection_type)
    error_message = "Supported are: JDBC, MONGODB, KAFKA, and NETWORK."
  }
}

variable "connection_properties" {
  type        = map(string)
  description = "A map of key-value pairs used as parameters for this connection."
  default     = null
}

variable "match_criteria" {
  type        = list(string)
  description = "A list of criteria that can be used in selecting this connection."
  default     = null
}

variable "physical_connection_requirements" {
  type = object({
    # The availability zone of the connection. This field is redundant and implied by subnet_id, but is currently an API requirement
    availability_zone = string
    # The security group ID list used by the connection
    security_group_id_list = list(string)
    #  The subnet ID used by the connection
    subnet_id = string
  })
  description = "Physical connection requirements, such as VPC and SecurityGroup."
  default     = null
}
