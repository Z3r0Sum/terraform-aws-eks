output "this_cluster_iam_role_arn" {
  description = "EKS Cluster IAM Role"
  value       = "${aws_iam_role.this_cluster.arn}"
}

output "this_node_iam_role_arn" {
  description = "EKS Node IAM Role"
  value       = "${aws_iam_role.this_node.arn}"
}

output "this_node_instance_profile_name" {
  description = "Worker Nodes IAM Instance Profile"
  value       = "${aws_iam_instance_profile.this_node.name}"
}
