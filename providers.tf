terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.66.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
 } 
  required_version = "~> 1.4"
}
  

