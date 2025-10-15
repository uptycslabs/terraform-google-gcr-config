/*
 * Copyright (c) 2023 Uptycs, Inc. All rights reserved
 */

terraform {
  required_version = ">= 0.13"
  required_providers {

    google = {
      source  = "hashicorp/google"
      version = "~> 4.53.1"
    }
  }

  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-iam-config/v1.0.0"
  }
}
