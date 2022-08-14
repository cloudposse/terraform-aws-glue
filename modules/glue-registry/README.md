# glue-registry

Terraform module to provision AWS Glue Registries.

## Usage

```hcl
module "glue_registry" {
  source = "cloudposse/glue/aws//modules/glue-registry"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  registry_name        = "analytics"
  registry_description = "Glue Registry for analytics"
}
```
