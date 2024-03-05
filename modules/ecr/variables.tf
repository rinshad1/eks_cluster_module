variable "repository_names" {
  description = "List of names for the ECR repositories"
  type        = list(any)
}

variable "image_tag_mutability" {
  type        = string
  description = "The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`"
}