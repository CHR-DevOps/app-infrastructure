output "k8s_public_ip" {
  value = aws_instance.k8s_main.public_ip
}

output "k8s_public_dns" {
  value = aws_instance.k8s_main.public_dns
}