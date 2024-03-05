resource "aws_eks_cluster" "cloudquicklabs" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cloudquicklabs.arn

  vpc_config {
    subnet_ids              = var.aws_public_subnet
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = [aws_security_group.node_group_one.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudquicklabs-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cloudquicklabs-AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_node_group" "cloudquicklabs" {
  cluster_name    = aws_eks_cluster.cloudquicklabs.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.cloudquicklabs2.arn
  subnet_ids      = var.aws_public_subnet
  instance_types  = var.instance_types

  remote_access {
    source_security_group_ids = [aws_security_group.node_group_one.id]
    ec2_ssh_key               = var.key_pair
  }

  scaling_config {
    desired_size = var.scaling_desired_size
    max_size     = var.scaling_max_size
    min_size     = var.scaling_min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudquicklabs-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.cloudquicklabs-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.cloudquicklabs-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_security_group" "node_group_one" {
  name_prefix = "node_group_one"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_iam_role" "cloudquicklabs" {
  name = "eks-cluster-cloudquicklabs"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cloudquicklabs-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cloudquicklabs.name
}

resource "aws_iam_role_policy_attachment" "cloudquicklabs-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cloudquicklabs.name
}

resource "aws_iam_role" "cloudquicklabs2" {
  name = "eks-node-group-cloudquicklabs"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "cloudquicklabs-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.cloudquicklabs2.name
}

resource "aws_iam_role_policy_attachment" "cloudquicklabs-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cloudquicklabs2.name
}

resource "aws_iam_role_policy_attachment" "cloudquicklabs-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.cloudquicklabs2.name
}

#######################################
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

# ############
# resource "kubernetes_cluster_role" "eks_reader_cluster_role" {
#   metadata {
#     name = "reader"
#   }
#   rule {
#     api_groups = [""]
#     resources  = ["pods", "nodes", "deployments", "replicasets"]
#     verbs      = ["get", "list", "watch"]
#   }
# }

# resource "kubernetes_cluster_role_binding" "eks_reader_cluster_role_binding" {
#   metadata {
#     name = "reader"
#   }
#   role_ref {
#     kind     = "ClusterRole"
#     name     = kubernetes_cluster_role.eks_reader_cluster_role.metadata[0].name
#     api_group = "rbac.authorization.k8s.io"
#   }
#   subject {
#     kind      = "User"
#     name      = "reader"
#     api_group = null
#   }
# }

# ##############


# resource "kubectl_config_map" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     mapRoles = <<EOF
#     - rolearn: "arn:aws:iam::039033235676:user/sanjay.pramod@urolime.com"
#       username: system:node:{{EC2PrivateDNSName}}
#       groups:
#         - reader
#     EOF
#   }
# }

