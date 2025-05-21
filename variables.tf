variable "common_tags" {
  type = map(string)
  default = {}
}

variable "product" {
  type = string
}

variable "env" {
  type = string
}

variable "jenkins_AAD_objectId" {
  description = "The object ID of the user to be granted access to the key vault"
}