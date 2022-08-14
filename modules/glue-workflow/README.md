# glue-workflow

Terraform module to provision AWS Glue Workflows.

## Usage

```hcl
module "glue_workflow" {
  source = "cloudposse/glue/aws//modules/glue-workflow"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  workflow_name          = "geo"
  workflow_description   = "Glue workflow to process geo data"
  max_concurrent_runs    = 2
  default_run_properties = {}
}
```
