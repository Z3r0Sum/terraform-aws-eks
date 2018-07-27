locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.this.endpoint}
    certificate-authority-data: ${aws_eks_cluster.this.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.eks_cluster_name}"
KUBECONFIG
}

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${module.eks-iam.this_node_iam_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "config_map_aws_auth" {
  description = "EKS ConfigMap for Nodes to join K8S cluster - apply independently"
  value       = "${local.config_map_aws_auth}"
}

output "eks_cluster_ca_data" {
  description = "EKS Cluster CA Data"
  value       = "${aws_eks_cluster.this.certificate_authority.0.data}"
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster Endpoint URL"
  value       = "${aws_eks_cluster.this.endpoint}"
}

output "eks_cluster_sg_id" {
  description = "SG ID for cluster communication with worker nodes"
  value       = "${module.eks-network.this_cluster_sg_id}"
}

output "eks_node_sg_id" {
  description = "EKS Worker Node SG ID"
  value       = "${module.eks-network.this_node_sg_id}"
}

output "eks_node_iam_role_arn" {
  description = "EKS Node IAM Role"
  value       = "${module.eks-iam.this_node_iam_role_arn}"
}

output "eks_node_instance_profile_name" {
  description = "Worker Nodes IAM Instance Profile Name"
  value       = "${module.eks-iam.this_node_instance_profile_name}"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}
