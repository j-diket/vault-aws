provider "aws" {
  # your AWS region
  region = "us-east-1"
}

module "vault-ent" {
  source  = "github.com/Insight-NA/terraform-aws-vault-ent"

  # prefix for tagging/naming AWS resources
  resource_name_prefix = "test"

  # VPC ID you wish to deploy into
  vpc_id = "vpc-abc123xxx"
  
  # private subnet IDs are required and allow you to specify which
  # subnets you will deploy your Vault nodes into
  private_subnet_ids = [
    "subnet-0xyz",
    "subnet-1xyz",
    "subnet-2xyz",
  ]
  
  # AWS Secrets Manager ARN where TLS certs are stored
  secrets_manager_arn = "arn:aws::secretsmanager:abc123xxx"
  
  # The shared DNS SAN of the TLS certs being used
  leader_tls_servername = "vault.server.com"
  
  # The cert ARN to be used on the Vault LB listener
  lb_certificate_arn = "arn:aws:acm:abc123xxx"

  vault_license_filepath = "/home/test/vault.hclic"
}