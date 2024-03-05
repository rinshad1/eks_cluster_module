output "ecr_repo_urls" {
  value = [for repo in aws_ecr_repository.demo-repository : repo.repository_url]
}
