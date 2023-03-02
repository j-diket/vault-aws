# Pull available AZs from current Region
data "aws_availability_zones" "available" {
  provider = aws.region1
  state = "available"
}

# Pull most recent AMI data
data "aws_ami" "latest-image" {
  provider = aws.region1
  most_recent = true
  owners = [ "099720109477" ]

  filter {
    name = "name"
    values = [ "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*" ]
  }

  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}