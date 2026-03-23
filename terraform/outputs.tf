output "dev_staging_public_ip" {
  value = aws_instance.k8s_devstaging.public_ip
}

output "prod_public_ip" {
  value = aws_instance.k8s_prod.public_ip
}