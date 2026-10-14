output "app_server_public_ip" {
  value = aws_instance.app.public_ip
}

output "s3_backup_bucket" {
  value = aws_s3_bucket.backup.id
}

output "ssh_command" {
  value = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.app.public_ip}"
}
