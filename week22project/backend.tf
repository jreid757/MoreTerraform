terraform {
  cloud {
    organization = "Level-Up-2023"

    workspaces {
      name = "aws-terraform-2-tier"
    }
  }
}