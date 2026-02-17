resource "aws_ecr_repository" "repo" {
  name                 = "cloud-janitor-ebs"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "null_resource" "docker_build_push" {
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset("${path.module}/../src", "*") : filesha1("${path.module}/../src/${f}")]))
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"] # Windows  ["PowerShell", "-Command"]
    command     = <<EOF
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.repo.repository_url}
      docker build --platform linux/amd64 --provenance=false -t ${aws_ecr_repository.repo.repository_url}:latest ../
      docker push ${aws_ecr_repository.repo.repository_url}:latest
    EOF
  }
}