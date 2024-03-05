module "eks" {
  source                  = "./modules/eks"
  aws_public_subnet       = module.vpc.aws_private_subnet
  vpc_id                  = module.vpc.vpc_id
  cluster_name            = var.cluster_name
  endpoint_public_access  = false
  endpoint_private_access = true
  public_access_cidrs     = var.public_access_cidrs
  node_group_name         = var.node_group_name
  scaling_desired_size    = var.scaling_desired_size
  scaling_max_size        = var.scaling_max_size
  scaling_min_size        = var.scaling_min_size
  instance_types          = var.instance_types
  key_pair                = var.key_pair
}

module "vpc" {
  source                  = "./modules/vpc"
  tags                    = var.tags
  tags2                   = var.tags2
  instance_tenancy        = var.instance_tenancy
  vpc_cidr                = var.vpc_cidr
  access_ip               = var.access_ip
  public_sn_count         = var.public_sn_count
  private_sn_count        = var.private_sn_count
  public_cidrs            = var.public_cidrs
  private_cidrs           = var.private_cidrs
  map_public_ip_on_launch = var.map_public_ip_on_launch
  rt_route_cidr_block     = var.rt_route_cidr_block

}

module "bastionhost" {
  source           = "./modules/bastionhost"
  vpc_id           = module.vpc.vpc_id
  key_name         = var.key_name
  subnet_id        = module.vpc.aws_public_subnet
  ami_id           = var.ami_id
  instance_type_BH = var.instance_type_BH
}

module "ecr" {
  source               = "./modules/ecr"
  repository_names     = var.repository_names
  image_tag_mutability = var.image_tag_mutability
}

###########################

# # Define the IAM Role
# resource "aws_iam_role" "eks_read_role" {
#   name               = "eks-read-role"
#   assume_role_policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "AWS" : "arn:aws:iam::039033235676:user/sanjay.pramod@urolime.com"
#         },
#         "Action" : "sts:AssumeRole"
#       }
#     ]
#   })
# }

# # Define the IAM Policy
# resource "aws_iam_policy" "eks_read_policy" {
#   name        = "eks-read-policy"
#   description = "Policy to allow read access to EKS cluster"

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Action": [
#           "eks:DescribeCluster",
#           "eks:ListClusters",
#           "eks:ListClusterTags",
#           "eks:ListNodegroups",
#           "eks:DescribeNodegroup",
#           "eks:ListNodegroups",
#           "eks:ListFargateProfiles",
#           "eks:DescribeFargateProfile",
#           "eks:ListUpdates",
#           "eks:DescribeUpdate",
#           "eks:ListAddonVersions",
#           "eks:DescribeAddonVersions",
#           "eks:DescribeAddon",
#           "eks:ListTagsForResource"
#         ],
#         "Resource": "*"
#       }
#     ]
#   })
# }

# # Attach the IAM Policy to the IAM Role
# resource "aws_iam_role_policy_attachment" "eks_read_policy_attachment" {
#   role       = aws_iam_role.eks_read_role.name
#   policy_arn = aws_iam_policy.eks_read_policy.arn
# }

# ############################
# resource "kubernetes_cluster_role" "eks_reader_cluster_role" {
#   metadata {
#     name = "reader"
#   }
#   rule {
#     api_groups = ["*"]
#     resources  = ["pods", "nodes", "deployments", "replicasets"]
#     verbs      = ["get", "list", "watch"]
#   }
# }

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }

# provider "kubernetes" {
#   # config_path = "./kube_config"  # Path to your kubeconfig file
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   token                  = data.aws_eks_cluster_auth.cluster.token
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
# }

# resource "kubernetes_cluster_role_binding" "eks_reader_cluster_role_binding" {
#   metadata {
#     name = "reader"
#   }
#   role_ref {
#     kind     = "ClusterRole"
#     name     = "reader"
#     api_group = "rbac.authorization.k8s.io"
#   }
#   subject {
#     kind      = "Group"
#     name      = "reader"
#     api_group = "rbac.authorization.k8s.io"
#   }
# }

# # provider "kubectl" {
# #   config_context_cluster = "YOUR_CLUSTER_NAME"
# # }

# resource "null_resource" "apply_config_map" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }

#   provisioner "local-exec" {
#     command = <<-EOF
#       echo '
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: aws-auth
#   namespace: kube-system
# data:
#   mapRoles: |
#     - rolearn: "arn:aws:iam::039033235676:user/sanjay.pramod@urolime.com"
#       username: sanjay.pramod@urolime.com
#       groups:
#         - reader
# ' | kubectl apply -f -
#     EOF
#   }
# }

