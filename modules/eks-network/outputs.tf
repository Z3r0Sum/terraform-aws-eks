output "this_cluster_sg_id" {
  description = "SG ID for cluster communication with worker nodes"
  value       = "${aws_security_group.this_cluster.id}"
}

output "this_node_sg_id" {
  description = "SG ID for all nodes in the cluster"
  value       = "${aws_security_group.this_node.id}"
}
