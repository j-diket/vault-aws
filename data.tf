data "aws_availability_zones" "available" {
  provider = aws.region1
  state = "available"
}