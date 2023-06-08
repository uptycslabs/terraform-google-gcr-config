# terraform-google-gcr-config

This module creates the necessary GCP resources to grant uptycs access to artifact registries for registry monitoring. Access is setup with Workload Identity Pool (WIP) with AWS as the identity provider. This avoids the need to manage sensitive keys.

This terraform module will create the following resources:

- Service account
- Workload Identity Pool
- Identity Provider AWS

In addition to these resources, the newly created service account will have the following roles attached to it:
- roles/artifactregistry.reader
- roles/iam.serviceAccountTokenCreator
- roles/storage.objectViewer

## Prerequisites

- Minimum required version of Terraform -> v0.13
- The user must have `Git` installed on the system that they are using to execute the Terraform script.
  - Instructions on how to install Git here: https://github.com/git-guides/install-git
- The user must also have the `gcloud` CLI installed and authenticated as described in both the [Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#configuring-the-provider) and [GCP](https://cloud.google.com/sdk/gcloud) documentation.

## Running the Terraform Module

- Create a file with name as `main.tf` and paste the code given below into it.

```hcl
module "gcr-config" {
  source            = "uptycslabs/gcr-config/google"
  
  uptycs_aws_account_id = "Copy/Paste From the Uptycs UI"
  gcp_project_id        = "Your GCP Project ID"
  service_account_name  = "uptycs-gcr-integration"

  # Copy the AWS Account ID from Uptycs UI
  # Uptycs' UI : "Configurations"->"Registry Configuration"->"ADD REGISTRY"
  integration_name   = "A unique name for this integration"
}

```
- Modify the ‘Input’ details as needed
- `uptycs_aws_account_id` must be copied from the Uptycs UI.


## Inputs

| Name                   | Description                                                           | Type     | Required |
| ---------------------  | --------------------------------------------------------------------- | -------- | -------- |
| uptycs_aws_account_id  | Aws account id of Uptycs                                              | `string` | Yes      |
| gcp_project_id         | Role external ID provided by Uptycs. Copy the UUID ID from Uptycs' UI | `string` | Yes      |
| integration_name       | A unique name for this GCP - uptycs integration                       | `string` | Yes      |
| service_account_name   | The name of the GCP service account to use for authentication         | `string` |          |
| service_account_exists | A boolean value indicating whether the service account already exists | `bool`   |          |


## Outputs

This module produces no terraform outputs, however, successfully running this module will result in a `credentials.json` file being generated in your working directory.

# GCP Authentication

Prior to executing this modiue, ensure that you are locally authenticated to GCP.

```sh
gcloud auth application-default login
```

# Execute Terraform Script to Generate `credentials.json`

```sh
$ terraform init -upgrade
$ terraform plan
$ terraform apply
```
