variable "eks_cluster_name" {
  type = "string"
}

variable "eks_default_ssh_key_name" {
  type = "string"
}

variable "eks_default_worker_group_name" {
  type    = "string"
  default = "default"
}

variable "eks_default_worker_instance_type" {
  type    = "string"
  default = "t2.medium"
}

variable "eks_default_worker_desired_capacity" {
  type    = "string"
  default = "1"
}

variable "eks_default_worker_max_size" {
  type    = "string"
  default = "1"
}

variable "eks_default_worker_min_size" {
  type    = "string"
  default = "1"
}

variable "eks_default_max_pods" {
  type    = "string"
  default = "17"
}

variable "eks_default_worker_ami_name" {
  type    = "string"
  default = "eks-worker-v20"
}

variable "eks_worker_public_ip_enable" {
  type = "string"
  default = "false"
}

variable "private_subnet_ids" {
  type = "list"
}

variable "public_subnet_ids" {
  type = "list"
}

variable "vpc_id" {
  type = "string"
}

variable "region" {
  type = "string"
}
