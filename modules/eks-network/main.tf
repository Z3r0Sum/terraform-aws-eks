##########################
#### Master SG Access ####
##########################
resource "aws_security_group" "this_cluster" {
  name        = "${var.eks_cluster_name}-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.eks_cluster_name}-cluster"
  }
}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "this_cluster_workstation_ingress" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.this_cluster.id}"
  to_port           = 443
  type              = "ingress"
}

###############################
#### Worker Node SG Access ####
###############################
resource "aws_security_group" "this_node" {
  name        = "${var.eks_cluster_name}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "${var.eks_cluster_name}-node",
     "kubernetes.io/cluster/${var.eks_cluster_name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "this_node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.this_node.id}"
  source_security_group_id = "${aws_security_group.this_node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "this_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.this_node.id}"
  source_security_group_id = "${aws_security_group.this_cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

###############################################
#### Internal K8S API Server Communication ####
###############################################
resource "aws_security_group_rule" "this_cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.this_cluster.id}"
  source_security_group_id = "${aws_security_group.this_node.id}"
  to_port                  = 443
  type                     = "ingress"
}
