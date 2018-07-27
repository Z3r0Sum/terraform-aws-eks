# EKS Terraform module

## Requirements

- Existing VPC: https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#base-vpc-networking
- Tags following the above guidelines on the VPC and subnets being used

## Usage

```hcl
module "eks" {
  source = "Z3r0Sum/eks/aws"

  eks_cluster_name                    = "eks-test"
  region                              = "us-east-1"
  private_subnet_ids                  = ["${aws_subnet_ids.private.*.id}"]
  public_subnet_ids                   = ["${aws_subnet_ids.public.*.id}"]
  vpc_id                              = "${aws_vpc.id}"

  # Default worker pool
  eks_worker_ssh_key_name             = "eks-worker-ssh-key"
  eks_worker_desired_capacity         = "1"
  eks_worker_max_size                 = "1"
  eks_worker_min_size                 = "1"
  eks_worker_public_ip_enable         = "false"

}
```

Additional worker pools:

```hcl
module "test_pool" {
  source = "Z3r0Sum/eks/aws/modules/eks-compute"

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

## Accessing Cluster

- `terraform output kubeconfig > ~/.kube/eks-kubeconfig`
- `export KUBECONFIG="~/.kube/eks-kubeconfig"`

## Authorize Nodes

- `terraform output config_map_aws_auth | kubectl apply -f -`

## Terraform version

Terraform version 0.11.7 or newer is required for this module to work.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| eks_cluster_name | Name give to EKS cluster | string | `` | yes |
| eks_worker_ssh_key_name | SSH Key to be assigned to a worker pool | string | `` | yes |
| eks_worker_group_name | Unique Name to be appended to Instances and ASG | string | `default` | yes |
| eks_worker_instance_type | Instance type that makes up that worker pool | string | `t2.medium` | yes |
| eks_worker_desired_capacity | ASG Desired Capacity for that worker pool | string | `1` | yes |
| eks_worker_max_size | ASG Max Size for that worker pool | string | `1` | yes |
| eks_worker_min_size | ASG Min Size for that worker pool | string | `1` | yes |
| eks_worker_max_pods | Max pods to run on instance (based on instance type - consult AWS Documentation) | string | `17` | yes |
| eks_worker_ami_name | AWS AMI to use for that worker pool | string | `eks-worker-v20` | yes |
| eks_worker_public_ip_enable | Enable Public IPs in ASG for worker pool | string | `false` | yes |
| private_subnet_ids | Private Subnet IDs in VPC to leverage for worker pool & Cluster | list | `` | yes |
| public_subnet_ids | Public Subnet IDs in VPC to leverage for worker pool & Cluster | list | `` | yes |
| region | AWS Region to deploy Cluster into (must be: us-east-1 or us-west-2) | string | `` | yes |
| vpc_id | VPC ID to leverage for cluster/worker pool(s) | string | `` | yes |

## Outputs

| Name | Description |
|------|-------------|
| config_map_aws_auth | K8S ConfigMap to apply for Nodes to join the cluster and Heptio Authenticator for IAM |
| eks_cluster_ca_data | EKS Cluster CA Cert Data |
| eks_cluster_endpoint | EKS Cluster Endpoint URL |
| eks_cluster_sg_id | SG ID for cluster communication with worker nodes (Control Plane SG) |
| eks_node_sg_id | EKS Worker Node SG ID |
| eks_node_iam_role_arn | EKS Node IAM Role |
| eks_node_instance_profile_name | Worker Nodes IAM Instance Profile Name |
| kubeconfig | K8S Kubeconfig used to access the cluster via 'kubectl' |

## License

Apache 2 Licensed. See LICENSE for full details.
