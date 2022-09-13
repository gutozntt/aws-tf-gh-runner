variable "runner_name" {
  type        = string
  description = "Name for your Runners."
  default     = "github-runner"
}
variable "ami" {
  type        = string
  description = "AMI ID for your Runners. Must be Amazon Linux 2."
  default     = null
}
variable "instance_type" {
  type        = string
  description = "EC2 Instance Type for your Runners."
}
variable "key_name" {
  type        = string
  description = "EC2 Key Pair Name for your Runners."
  default     = null
}
variable "monitoring" {
  type        = bool
  description = "Whether to enable monitoring for your Runners."
  default     = false
}
variable "iam_instance_profile" {
  type        = string
  description = "IAM Role for your Runners."
  default     = null
}
variable "vpc_security_group_ids" {
  type        = list(any)
  description = "List of Security Groups for your Runners."
}
variable "subnet_id" {
  type        = string
  description = "Subnet ID for your Runners."
}
variable "region" {
  type        = string
  description = "AWS Region for your Runners."
}
variable "label" {
  type        = string
  description = "Github Labels for your Runners."
}
variable "runner_architecture" {
  type        = string
  description = "Architecture for your Runners. It should be one of the following: x64, ARM or ARM64"
}