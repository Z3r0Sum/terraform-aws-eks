module "eks-iam" {
  source = "./modules/eks-iam"

  eks_cluster_name = "${var.eks_cluster_name}"
}

module "eks-network" {
  source = "./modules/eks-network"

  eks_cluster_name = "${var.eks_cluster_name}"
  vpc_id           = "${var.vpc_id}"
}

resource "aws_eks_cluster" "this" {
  name     = "${var.eks_cluster_name}"
  role_arn = "${module.eks-iam.this_cluster_iam_role_arn}"

  vpc_config {
    security_group_ids = ["${module.eks-network.this_cluster_sg_id}"]
    subnet_ids         = ["${concat(var.private_subnet_ids, var.public_subnet_ids)}"]
  }
}

module "default-workers" {
  source = "./modules/eks-compute"

  region                      = "${var.region}"
  eks_cluster_name            = "${var.eks_cluster_name}"
  eks_cluster_ca_data         = "${aws_eks_cluster.this.certificate_authority.0.data}"
  eks_cluster_endpoint        = "${aws_eks_cluster.this.endpoint}"
  eks_worker_ami_name         = "${var.eks_worker_ami_name}"
  eks_worker_sg_id            = "${module.eks-network.this_node_sg_id}"
  eks_worker_instance_profile = "${module.eks-iam.this_node_instance_profile_name}"

  # LC/ASG Settings
  eks_ssh_key_name            = "${var.eks_default_ssh_key_name}"
  eks_worker_subnet_ids       = "${var.private_subnet_ids}"
  eks_worker_public_ip_enable = "${var.eks_worker_public_ip_enable}"
  eks_worker_group_name       = "${var.eks_default_worker_group_name}"
  eks_worker_ami_name         = "${var.eks_default_worker_ami_name}"
  eks_worker_instance_type    = "${var.eks_default_worker_instance_type}"
  eks_worker_desired_capacity = "${var.eks_default_worker_desired_capacity}"
  eks_worker_max_size         = "${var.eks_default_worker_max_size}"
  eks_worker_min_size         = "${var.eks_default_worker_min_size}"

  # K8S Setting for Node from: https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml
  # Based on:
  # * First IP on each ENI is not used for pods
  # * 2 additional host-networking pods (AWS ENI and kube-proxy) are accounted for
  # number of ENI * (number of IPv4 per ENI - 1)  + 2
  # Should be based off instance type
  eks_max_pods = "${var.eks_default_max_pods}"
}
