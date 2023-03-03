resource "random_id" "deployment_tag" {
  byte_length = 4
}

locals {
  tags = merge(
    var.tags,
    {
        "DeploymentTag" = random_id.deployment_tag.hex
    }
  )
}

##############################################
# Bastion VPC
##############################################

# module "bastion_vpc" {
#   source = "terraform-aws-modules/vpc/aws"
#   name = "${random_id.deployment_tag.hez}-bastion"

#   cidr = "192.168.0.0/16"

#   azs = [data.aws_availability_zones.available.names[0]]
#   private_subnets = ["192.168.1.0/24"]
#   public_subnets = ["192.168.101.0/24"]

#   enable_nat_gateway = true
#   single_nat_gateway = true
  
#   enable_dns_hostnames = true
#   enable_dns_support = true

#   public_subnet_tags = {
#     Name = "public-${random_id.deployment_tag.hex}"
#   }

#   tags = local.tags

#   vpc_tags = {
#     Name = "${random_id.deployment_tag.hex}-vpc"
#   }

#   providers = {
#     aws = aws.region1 
#    }
# }

##############################################
# Host VPC for Primary Cluster
##############################################

locals {
  max_subnet_length = max(
    length(var.private_subnets),
    length(var.elasticache_subnets),
    length(var.database_subnets),
    length(var.redshift_subnets),
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length

  vpc_id = try(aws_vpc_ipv4_cidr_block_association.this[0].vpc_id, aws_vpc.this[0].id, "")

  create_vpc = var.create_vpc && var.putin_khuylo
}

resource "aws_vpc" "primary" {
  count = local.create_vpc ? 1 : 0

  cidr_block = var.use_ipam_pool ? null : var.cidr
  ipv4_ipam_pool_id = var.ipv4_ipam_pool_id
}

##############################################
# Security Groups
##############################################
resource "aws_default_security_group" "bastion_default" {
  provider = aws.region1
  vpc_id = module.bastion_vpc.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key" {
  provider = aws.region1
  key_name = "${random_id.deployment_tag.hex}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_instance" "bastion" {
  provider = aws.region1
  ami = data.aws_ami.latest-image.id
  instance_type = "t3.micro"
  subnet_id = module.bastion_vpc.public_subnets[0]
  key_name = aws_key_pair.key.key_name
  user_data = base64encode(
    templatefile("${path.module}/bastion_template.tmpl", {})
  )

  tags = merge(local.tags, {
    "Name" = "bastion"
  })
}

resource "null_resource" "update_hosts" {
  provisioner "local-exec" {
    command = <<EOC
        cat <<-EOF >> /etc/ssh/ssh_config
        Host bastion
        HostName ${aws_instance.bastion.public_ip}
        User ubuntu
        IdentityFile ${abspath(local_sensitive_file.private_key.filename)}
    EOF
        EOC
  }
}