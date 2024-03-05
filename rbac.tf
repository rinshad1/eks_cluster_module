# Define the IAM Role
resource "aws_iam_role" "eks_read_role" {
  name               = "eks-read-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${var.iam_user_arn}"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Define the IAM Policy
resource "aws_iam_policy" "eks_read_policy" {
  name        = "eks-read-policy"
  description = "Policy to allow read access to EKS cluster"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListClusterTags",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:ListFargateProfiles",
          "eks:DescribeFargateProfile",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "eks:ListAddonVersions",
          "eks:DescribeAddonVersions",
          "eks:DescribeAddon",
          "eks:ListTagsForResource"
        ],
        "Resource": "*"
      }
    ]
  })
}

# Attach the IAM Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "eks_read_policy_attachment" {
  role       = aws_iam_role.eks_read_role.name
  policy_arn = aws_iam_policy.eks_read_policy.arn
}

############################

resource "kubernetes_cluster_role" "eks_reader_cluster_role" {
  metadata {
    name = "reader"
  }
  rule {
    api_groups = ["*"]
    resources  = ["pods", "nodes", "deployments", "replicasets"]
    verbs      = ["get", "list", "watch"]
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  # config_path = "./kube_config"  # Path to your kubeconfig file
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

resource "kubernetes_cluster_role_binding" "eks_reader_cluster_role_binding" {
  metadata {
    name = "reader"
  }
  role_ref {
    kind     = "ClusterRole"
    name     = "reader"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "Group"
    name      = "reader"
    api_group = "rbac.authorization.k8s.io"
  }
}


resource "null_resource" "apply_config_map" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOF
      echo '
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: "${var.iam_user_arn}"
      username: "${var.iam_user_name}"
      groups:
        - reader
' | kubectl apply -f -
    EOF
  }
}

