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