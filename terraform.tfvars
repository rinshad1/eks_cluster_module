cluster_name            = "eks-cluster-123"
key_pair                = "eks"
instance_types          = ["t3.medium"]
instance_type_BH        = "t3.micro"
node_group_name         = "eks-cluster-123-node-group"
public_access_cidrs     = ["0.0.0.0/0"]
tags                    = "cluster-123-vpc"
tags2                   = "cluster-123-vpc2"
vpc_cidr                = "10.0.0.0/16"
instance_tenancy        = "default"
public_sn_count         = "2"
private_sn_count        = "2"
public_cidrs            = ["10.0.1.0/24", "10.0.2.0/24"]
private_cidrs           = ["10.0.3.0/24", "10.0.4.0/24"]
rt_route_cidr_block     = "0.0.0.0/0"
access_ip               = "0.0.0.0/0"
scaling_desired_size    = "6"
scaling_max_size        = "8"
scaling_min_size        = "6"
map_public_ip_on_launch = "true"
key_name                = "eks"
ami_id                  = "ami-008fe2fc65df48dac"

#ecr variables
repository_names     = ["repo-dev", "repo-prod"]
image_tag_mutability = "MUTABLE"

#RBAC
iam_user_arn         = "arn:aws:iam::1234567890:user/abc@xyz.com"
iam_user_name        = "abc@xyz.com"
