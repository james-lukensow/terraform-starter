variable "primaryRegion" {
  type = string
}

variable "env" {
  type = string
}

variable "apiDomain" {
  type = string
}

variable "projectPrefix" {
  type = string
}

variable "stateBucket" {
  type = string
}

variable "stateBucketAccountKey" {
  type = string
}

variable "ecsServiceCount" {
  type = number
}

variable "ecsDefinitionCpu" {
  type = number
}

variable "ecsDefinitionMemory" {
  type = number
}