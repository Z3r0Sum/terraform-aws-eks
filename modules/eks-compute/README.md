# EKS Terraform Submodule Compute

## Usage

Additional worker pools:

```hcl
module "test_pool" {
  source = "Z3r0Sum/eks/aws//modules/eks-compute"

  eks_cluster_name            = "eks-test"
  eks_cluster_ca_data         = "${module.eks.eks_cluster_ca_data}"
  eks_cluster_endpoint        = "${module.eks.eks_cluster_endpoint}"
  eks_worker_max_pods         = "2"
  eks_worker_ssh_key_name     = "eks-worker-ssh-key"
  eks_worker_instance_type    = "t2.nano"
  eks_worker_desired_capacity = "1"
  eks_worker_max_size         = "1"
  eks_worker_min_size         = "1"
  eks_worker_instance_profile = "${module.eks.eks_node_instance_profile_name}"

  eks_worker_group_name       = "test-pool"
  eks_worker_sg_id            = "${module.eks.eks_node_sg_id}"
  eks_worker_subnet_ids       = ["${aws_subnet_ids.private.*.id}"]
  eks_worker_public_ip_enable = "false"
  region                      = "us-east-1"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| eks_cluster_name | Name give to EKS cluster | string | `` | yes |
| eks_cluster_ca_data | Certificate Data from the EKS CA | string | `` | yes |
| eks_cluster_endpoint | EKS Cluster Endpoint | string | `` | yes |
| eks_worker_ssh_key_name | SSH Key to be assigned to a worker pool | string | `` | yes |
| eks_worker_ami_name | EKS AMI to use for worker pool | string | `eks-worker-v20` | yes |
| eks_worker_group_name | Unique Name to be appended to Instances and ASG | string | `` | yes |
| eks_worker_instance_type | Instance type that makes up that worker pool | string | `t2.medium` | yes |
| eks_worker_desired_capacity | ASG Desired Capacity for that worker pool | string | `1` | yes |
| eks_worker_max_size | ASG Max Size for that worker pool | string | `1` | yes |
| eks_worker_min_size | ASG Min Size for that worker pool | string | `1` | yes |
| eks_worker_instance_profile | Instance profile to assing to the worker pool | string | `` | yes |
| eks_worker_max_pods | Max pods to run on instance (based on instance type - consult AWS Documentation) | string | `17` | yes |
| eks_worker_ami_name | AWS AMI to use for that worker pool | string | `eks-worker-v20` | yes |
| eks_worker_public_ip_enable | Enable Public IPs in ASG for worker pool | string | `false` | yes |
| eks_worker_sg_id | Security Group ID for the Worker Pool | string | `` | yes |
| eks_worker_subnet_ids | List of Subnet IDs for the Worker Pool | list | `` | yes |
| region | AWS Region to deploy Cluster into (must be: us-east-1 or us-west-2) | string | `` | yes |
