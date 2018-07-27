data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["${var.eks_worker_ami_name}"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml
locals {
  node_userdata = <<USERDATA
#!/bin/bash -xe

CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki
CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt
mkdir -p $CA_CERTIFICATE_DIRECTORY
echo "${var.eks_cluster_ca_data}" | base64 -d >  $CA_CERTIFICATE_FILE_PATH
INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i s,MASTER_ENDPOINT,${var.eks_cluster_endpoint},g /var/lib/kubelet/kubeconfig
sed -i s,CLUSTER_NAME,${var.eks_cluster_name},g /var/lib/kubelet/kubeconfig
sed -i s,REGION,${var.region},g /etc/systemd/system/kubelet.service
sed -i s,MAX_PODS,${var.eks_max_pods},g /etc/systemd/system/kubelet.service
sed -i s,MASTER_ENDPOINT,${var.eks_cluster_endpoint},g /etc/systemd/system/kubelet.service
sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service
DNS_CLUSTER_IP=10.100.0.10
if [[ $INTERNAL_IP == 10.* ]] ; then DNS_CLUSTER_IP=172.20.0.10; fi
sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g /etc/systemd/system/kubelet.service
sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig
sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g  /etc/systemd/system/kubelet.service
systemctl daemon-reload
systemctl restart kubelet
USERDATA
}

resource "aws_launch_configuration" "this" {
  associate_public_ip_address = true
  iam_instance_profile        = "${var.eks_worker_instance_profile}"
  image_id                    = "${data.aws_ami.eks_worker.id}"
  instance_type               = "${var.eks_worker_instance_type}"
  key_name                    = "${var.eks_ssh_key_name}"
  name_prefix                 = "${var.eks_cluster_name}-${var.eks_worker_group_name}"
  security_groups             = ["${var.eks_worker_sg_id}"]
  user_data_base64            = "${base64encode(local.node_userdata)}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  desired_capacity     = "${var.eks_worker_desired_capacity}"
  launch_configuration = "${aws_launch_configuration.this.id}"
  max_size             = "${var.eks_worker_max_size}"
  min_size             = "${var.eks_worker_min_size}"
  name                 = "${var.eks_cluster_name}-${var.eks_worker_group_name}"
  vpc_zone_identifier  = ["${var.eks_worker_subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "${var.eks_cluster_name}-${var.eks_worker_group_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.eks_cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
