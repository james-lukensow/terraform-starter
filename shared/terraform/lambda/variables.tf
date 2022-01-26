variable "name" {
  type = string
}

variable "permissions" {
  type = string
}

variable "timeout" {
  type = number  
}

variable "memory_size" {
  type = number
}

variable "variables" {
  type = map(string)
}

variable "vpc_config" {
  type = object({
    subnet_ids = list(string)
    security_group_ids = list(string)
  })
  default = null
}
