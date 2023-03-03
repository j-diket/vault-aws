# resource "tls_private_key" "ssh" {
#   algorithm = "RSA"
#   rsa_bits = "4096"
# }

# resource "local_sensitive_file" "private_key" {
#   content = tls_private_key.ssh.private_key_pem
#   filename = "${path.module}/${random_id.deployment_tag.hex}-key.pem"
#   file_permission = "0400"
# }