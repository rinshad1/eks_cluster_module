variable "cluster_name" {}
variable "key_pair" {}
variable "instance_types" {}
variable "node_group_name" {}
variable "public_access_cidrs" {}
variable "tags" {}
variable "tags2" {}
variable "vpc_cidr" {}
variable "instance_tenancy" {}
variable "public_sn_count" {}
variable "private_sn_count" {}
variable "public_cidrs" {
  type = list(any)
}
variable "private_cidrs" {
  type = list(any)
}
variable "rt_route_cidr_block" {}
variable "access_ip" {}
variable "scaling_desired_size" {}
variable "scaling_max_size" {}
variable "scaling_min_size" {}
variable "map_public_ip_on_launch" {

}
variable "key_name" {
  description = "Key name of the Key Pair to use for the instance"
}
variable "ami_id" {
  description = "The AMI to be used for the bastion host"
}
variable "instance_type_BH" {
  description = "Instance type for the bastion host"
  # default     = "t3.micro"
}
variable "image_tag_mutability" {
  type        = string
  description = "The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`"
}

variable "repository_names" {
  description = "List of names for the ECR repositories"
  type        = list(any)
}

#RBAC

variable "iam_user_arn" {
  description = "ARN of the IAM user"
}

variable "iam_user_name" {
  description = "User Name of the IAM user"
}