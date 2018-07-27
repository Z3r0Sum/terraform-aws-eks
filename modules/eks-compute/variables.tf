variable "eks_cluster_name" {
  type = "string"
}

variable "eks_cluster_ca_data" {
  type = "string"
}

variable "eks_cluster_endpoint" {
  type = "string"
}

variable "eks_worker_max_pods" {
  type = "string"
}

variable "eks_worker_ssh_key_name" {
  type = "string"
}

variable "eks_worker_ami_name" {
  type    = "string"
  default = "eks-worker-v20"
}

variable "eks_worker_instance_type" {
  type    = "string"
  default = "t2.medium"
}

variable "eks_worker_desired_capacity" {
  type    = "string"
  default = "1"
}

variable "eks_worker_min_size" {
  type    = "string"
  default = "1"
}

variable "eks_worker_max_size" {
  type    = "string"
  default = "1"
}

variable "eks_worker_instance_profile" {
  type = "string"
}

variable "eks_worker_group_name" {
  type = "string"
}

variable "eks_worker_sg_id" {
  type = "string"
}

variable "eks_worker_subnet_ids" {
  type = "list"
}

variable "eks_worker_public_ip_enable" {
  type    = "string"
  default = "false"
}

variable "region" {
  type = "string"
}
