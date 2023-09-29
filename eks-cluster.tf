data "aws_ami" "bottlerocket_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${local.cluster_version}-x86_64-*"]
  }
}

resource "aws_eip" "nat" {
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = module.vpc.public_subnets[0]
}

resource "aws_route_table" "private" {
   vpc_id = module.vpc.vpc_id
}

resource "aws_route" "nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# resource "aws_route_table_association" "private" {
#   subnet_id      = module.vpc.private_subnets[0]
#   route_table_id = aws_route_table.private.id
#   # force it to make sure it is in the same zone as the nat gateway
#     depends_on = [aws_nat_gateway.nat]
    
# }


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  eks_managed_node_group_defaults = {
    attach_cluster_primary_security_group = true
    # Disabling and using externally provided security groups
    create_security_group = false
    subnet_ids            = [module.vpc.private_subnets[0], module.vpc.public_subnets[0]] # force zone a
  }
  node_security_group_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = null
    # https://github.com/kubernetes/cloud-provider-aws/issues/27
    # https://github.com/kubernetes-sigs/cluster-api-provider-aws/issues/729
    # if not added aws prevents load balancers from working hence ingress
  }

  eks_managed_node_groups = {
    one = {
      name           = "group-1"
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      min_size       = 3
      max_size       = 3
      desired_size   = 3
      vpc_security_group_ids = [
        aws_security_group.group_one.id
      ]
    }
  }
  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}