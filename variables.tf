variable "region" {
  description = "AWS region for the EKS cluster"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "vpc cidr block"
  default     = "10.0.0.0/16"
  type        = string

}
variable "public_subnet" {
  description = "public subnets"
  default     = ["eks-public-subnet1", "eks-public-subnet2", "eks-public-subnet3"]
  type        = list(string)
}
variable "cidrs" {
  description = "public cidr block"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
  type        = list(string)
}
variable "az" {
  description = "avalability zone"
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  type        = list(string)
}
variable "route-names" {
  description = "route names"
  default     = ["eks-public1", "eks-public2", "eks-public3"]
  type        = list(string)
}
# variable "cluster-name" {
#     description = "cluster name"
#     default = "eks-cluster"
#     type = list(string)
# }
# variable "subnet_ids" {
#     description = "public subnet ids"
#     default = ["subnet-0a700947ce87c2851", "subnet-042b0c1aba972702e",]
#     type = list(string)
# }
# variable "vpc_id" {
#     description = 
#     default = "vpc-0b51ab8bbdc164d6a"
#     type = string
# }

