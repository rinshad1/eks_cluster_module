# modules/eks/variables.tf

variable "aws_public_subnet" {
  description = "The public subnet ID where the EKS cluster will be deployed."
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed."
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
}

variable "endpoint_private_access" {
  description = "Set to 'true' to enable private access to the EKS API server."
}

variable "endpoint_public_access" {
  description = "Set to 'true' to enable public access to the EKS API server."
}

variable "public_access_cidrs" {
  description = "CIDR blocks for allowing access to the EKS API server from the public internet."
}

variable "node_group_name" {
  description = "The name of the EKS node group."
}

variable "scaling_desired_size" {
  description = "The desired number of worker nodes in the node group."
}

variable "scaling_max_size" {
  description = "The maximum number of worker nodes in the node group."
}

variable "scaling_min_size" {
  description = "The minimum number of worker nodes in the node group."
}

variable "instance_types" {
  description = "A list of EC2 instance types for the node group."
}

variable "key_pair" {
  description = "The name of the EC2 key pair to use for the worker nodes."
}
