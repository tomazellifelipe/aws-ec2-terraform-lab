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