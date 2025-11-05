output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "ssh_command" {
  description = "Example SSH command (admin keypair)"
  value       = "ssh -i ${var.admin_pem_file_path} ec2-user@${aws_instance.this.public_ip}"
}

output "curl_command" {
  description = "Example curl command to test the web server"
  value       = "curl http://${aws_instance.this.public_ip}"
}

output "app_url" {
  value = "http://${aws_instance.this.public_ip}"
}