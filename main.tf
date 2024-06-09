resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "eks-vpc"
    automated = "yes"

  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "eks-igw"
    automated = "yes"
  }

}

resource "aws_subnet" "public-subnets" {
    count = 2
    vpc_id = aws_vpc.main.id
    cidr_block = element((var.cidrs), count.index)
    availability_zone = element((var.az), count.index)
    map_public_ip_on_launch = true

     tags = {
        Name = "${element(var.public_subnet, count.index)}"
     }
}
resource "aws_route_table" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "eks-route-table"
        automated = "yes"
    }

}

resource "aws_route" "main" {
    count = 2
    destination_cidr_block = "0.0.0.0/0"
    route_table_id = element(aws_route_table.main.*.id, count.index)
    gateway_id = aws_internet_gateway.main.id
}
resource "aws_route_table_association" "main" {
    count = 2
    subnet_id = element((aws_subnet.public-subnets.*.id), count.index)
    route_table_id = element(aws_route_table.main.*.id, count.index)
}
resource "aws_security_group" "main" {
    name = "alloxw_tls"
    description = "Allow TLS inbound traffic"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "Custom TCP from VPC"
        from_port   = 0
        to_port = 0
        protocol = -1
        cidr_blocks = [aws_vpc.main.cidr_block]
    }
    # ingress {
    #     description = "HTTPS from VPC"
    #     from_port   = 443
    #     to_port = 443
    #     protocol = ""
    #     cidr_blocks = ["31.94.66.215/32"]

    # }

    # ingress {
    #     description = "SSH from VPC"
    #     from_port = 22
    #     to_port = 22
    #     protocol = "tcp"
    #     cidr_blocks = ["31.94.66.215/32"]
    # }

    egress {
        description = "HTTP from VPC"
        from_port   = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

        tags = {
            Name = "-eks-sg"
        }
}

resource "aws_iam_role" "eks-cluster" {
  name = "new-eks-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "eks_cluster_attachment" {
  name       = "eks-cluster-attachment"
  roles      = [aws_iam_role.eks-cluster.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_policy_attachment" "admin_access_attachment" {
  name       = "admin-access-attachment"
  roles      = [aws_iam_role.eks-cluster.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_eks_cluster" "main" {
 name     = "eks-cluster"
 role_arn = aws_iam_role.eks-cluster.arn

 vpc_config {
   subnet_ids = aws_subnet.public-subnets[*].id
  }

  #Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  #Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
   aws_iam_policy_attachment.eks_cluster_attachment,
    aws_iam_policy_attachment.admin_access_attachment
 ]
}

# output "endpoint" {
#  value = aws_eks_cluster.main.endpoint
# }

# output "kubeconfig-certificate-authority-data" {
#  value = aws_eks_cluster.main.certificate_authority[0].data
# }











output "eks_role_arn" {
  value = aws_iam_role.eks-cluster.arn
}

resource "aws_iam_role" "node_group" {
  name = "node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "node_group_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "nodegroup"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = aws_subnet.public-subnets[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.node_group_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_policy,
  ]
}

# Local-exec provisioner to update kubeconfig after EKS cluster creation
resource "null_resource" "update_kubeconfig" {
  depends_on = [aws_eks_cluster.main]

  provisioner "local-exec" {
    command = "aws eks --region eu-west-2 update-kubeconfig --name eks-cluster"
  }
}

