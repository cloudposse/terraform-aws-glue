variable "partition_index" {
  type = object({
    index_name = string
    keys       = list(string)
  })
  description = "(Deprecated) Configuration block for a maximum of 3 partition indexes.)"
  default     = null
}