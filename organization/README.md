# Organization-level GCR Configuration Module

This module creates the necessary GCP resources to grant Uptycs access to artifact registries at the **organization level** for registry monitoring. Access is setup with Workload Identity Pool (WIP) with AWS as the identity provider. This avoids the need to manage sensitive keys.

This terraform module will create the following resources:

- Service account
- Workload Identity Pool
- Identity Provider AWS

In addition to these resources, the newly created service account will have the following roles attached **at the organization level**:
- roles/artifactregistry.reader
- roles/iam.serviceAccountTokenCreator
If gcr_integration is true, the following role will also be attached:
- roles/storage.objectViewer

## Prerequisites

- Minimum required version of Terraform -> v0.13
- The user must have `Git` installed on the system that they are using to execute the Terraform script.
  - Instructions on how to install Git here: https://github.com/git-guides/install-git
- The user must also have the `gcloud` CLI installed and authenticated as described in both the [Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#configuring-the-provider) and [GCP](https://cloud.google.com/sdk/gcloud) documentation.
- Organization-level IAM permissions to grant roles at the organization level

## Running the Terraform Module

- Create a file with name as `main.tf` and paste the code given below into it.

```hcl
module "gcr-config-org" {
  source = "uptycslabs/gcr-config/google//organization"
  
  uptycs_aws_instance_roles = ["Copy/Paste From the Uptycs UI"]
  gcp_host_project_id       = "Your GCP Project ID where the service account will be created"
  org_id                    = "Your GCP Organization ID"
  service_account_name      = "uptycs-gcr-integration"

  # Copy the AWS Account ID from Uptycs UI
  # Uptycs' UI : "Configurations"->"Registry Configuration"->"ADD REGISTRY"
  uptycs_aws_account_id     = "Copy/Paste From the Uptycs UI"

  integration_name = "A unique name for this integration"
}
```

- Modify the 'Input' details as needed
- `uptycs_aws_account_id` must be copied from the Uptycs UI.

## Inputs

| Name                      | Description                                                              | Type     | Required |
| ------------------------  | ------------------------------------------------------------------------ | -------- | -------- |
| uptycs_aws_account_id     | AWS account id of Uptycs                                                 | `string` | Yes      |
| uptycs_aws_instance_roles | Instances roles to be specified as the Workload Identity Binding members | `array`  | Yes      |
| gcp_host_project_id       | The GCP project ID where the service account and workload identity pool will be created | `string` | Yes      |
| org_id                    | The GCP organization ID where resources will be managed                  | `string` | Yes      |
| integration_name          | A unique name for this GCP - Uptycs integration                          | `string` | Yes      |
| service_account_name      | The name of the GCP service account to use for authentication            | `string` | Yes      |
| service_account_exists    | A boolean value indicating whether the service account already exists    | `bool`   | No       |
| gcr_integration           | Enable legacy GCR integration (default false)                            | `bool`   | No       |


## Outputs

This module produces no terraform outputs, however, successfully running this module will result in a `credentials.json` file being generated in your working directory.

## GCP Authentication

Prior to executing this module, ensure that you are locally authenticated to GCP.

```sh
gcloud auth application-default login
```

## Execute Terraform Script to Generate `credentials.json`

```sh
$ terraform init -upgrade
$ terraform plan
$ terraform apply
```

## Organization vs Project Level Integration

This module differs from the base module in the following ways:

1. It grants IAM roles at the **organization level**
2. It provides organization-wide access to artifact registries

Use this module when you need to monitor artifact registries across your entire GCP organization.

### Service Account Location

The service account and workload identity pool are created in the project specified by `gcp_host_project_id`, while the permissions are granted at the organization level. This allows you to have a single service account that has access to the entire organization.

