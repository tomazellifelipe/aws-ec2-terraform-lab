variable "access_key" {
  type        = string
  description = "aws access key"
  sensitive   = true
}
variable "secret_key" {
  type        = string
  description = "aws secret key"
  sensitive   = true
}
variable "token" {
  type        = string
  description = "aws session token"
  sensitive   = true
}
variable "autoscaling" {
  type = object({
    desired_capacity = number
    max_size         = number
    min_size         = number
  })
  description = "Atuscaling values"
  default = {
    desired_capacity = 1
    max_size         = 1
    min_size         = 1
  }
}