# glue-crawler

Terraform module to provision AWS Glue Crawlers.

## Usage

```hcl
module "s3_bucket_source" {
  source  = "cloudposse/s3-bucket/aws"
  version = "2.0.3"

  acl                          = "private"
  versioning_enabled           = false
  force_destroy                = true
  allow_encrypted_uploads_only = true
  allow_ssl_requests_only      = true
  block_public_acls            = true
  block_public_policy          = true
  ignore_public_acls           = true
  restrict_public_buckets      = true

  attributes = ["source"]
  context    = module.this.context
}

module "iam_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.16.2"

  principals = {
    "Service" = ["glue.amazonaws.com"]
  }

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  ]

  policy_document_count = 0
  policy_description    = "Policy for AWS Glue with access to EC2, S3, and Cloudwatch Logs"
  role_description      = "Role for AWS Glue with access to EC2, S3, and Cloudwatch Logs"

  context = module.this.context
}

module "s3_bucket_destination" {
  source  = "cloudposse/s3-bucket/aws"
  version = "2.0.3"

  acl                          = "private"
  versioning_enabled           = false
  force_destroy                = true
  allow_encrypted_uploads_only = true
  allow_ssl_requests_only      = true
  block_public_acls            = true
  block_public_policy          = true
  ignore_public_acls           = true
  restrict_public_buckets      = true

  attributes = ["destination"]
  context    = module.this.context
}

module "glue_catalog_database" {
  source = "cloudposse/glue/aws//modules/glue-catalog-database"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  catalog_database_name        = "analytics"
  catalog_database_description = "Glue Catalog database using data located in an S3 bucket"
  location_uri                 = format("s3://%s", module.s3_bucket_source.bucket_id)

  context = module.this.context
}

module "glue_crawler" {
  source = "cloudposse/glue/aws//modules/glue-crawler"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  crawler_description = "Glue crawler that processes data in the source S3 bucket and writes the result into the destination S3 bucket"
  database_name       = module.glue_catalog_database.name
  role                = module.iam_role.arn
  schedule            = "cron(0 1 * * ? *)"

  schema_change_policy = {
    delete_behavior = "LOG"
    update_behavior = null
  }

  s3_target = [
    {
      path = format("s3://%s", module.s3_bucket_destination.bucket_id)
    }
  ]

  configuration = jsonencode(
    {
      Grouping = {
        TableGroupingPolicy = "CombineCompatibleSchemas"
      }
      CrawlerOutput = {
        Partitions = {
          AddOrUpdateBehavior = "InheritFromTable"
        }
      }
      Version = 1
    }
  )

  context = module.this.context
}
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.74.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.74.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_glue_crawler.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_catalog_target"></a> [catalog\_target](#input\_catalog\_target) | List of nested Glue catalog target arguments. | <pre>list(object({<br/>    database_name = string<br/>    tables        = list(string)<br/>  }))</pre> | `null` | no |
| <a name="input_classifiers"></a> [classifiers](#input\_classifiers) | List of custom classifiers. By default, all AWS classifiers are included in a crawl, but these custom classifiers always override the default classifiers for a given classification. | `list(string)` | `null` | no |
| <a name="input_configuration"></a> [configuration](#input\_configuration) | JSON string of configuration information. | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_crawler_description"></a> [crawler\_description](#input\_crawler\_description) | Glue crawler description. | `string` | `null` | no |
| <a name="input_crawler_name"></a> [crawler\_name](#input\_crawler\_name) | Glue crawler name. If not provided, the name will be generated from the context. | `string` | `null` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Glue catalog database. | `string` | n/a | yes |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_delta_target"></a> [delta\_target](#input\_delta\_target) | List of nested Delta target arguments. | <pre>list(object({<br/>    connection_name = string<br/>    delta_tables    = list(string)<br/>    write_manifest  = bool<br/>  }))</pre> | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dynamodb_target"></a> [dynamodb\_target](#input\_dynamodb\_target) | List of nested DynamoDB target arguments. | `list(any)` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_jdbc_target"></a> [jdbc\_target](#input\_jdbc\_target) | List of nested JBDC target arguments. | `list(any)` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_lineage_configuration"></a> [lineage\_configuration](#input\_lineage\_configuration) | Specifies data lineage configuration settings for the crawler. | <pre>object({<br/>    crawler_lineage_settings = string<br/>  })</pre> | `null` | no |
| <a name="input_mongodb_target"></a> [mongodb\_target](#input\_mongodb\_target) | List of nested MongoDB target arguments. | `list(any)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_recrawl_policy"></a> [recrawl\_policy](#input\_recrawl\_policy) | A policy that specifies whether to crawl the entire dataset again, or to crawl only folders that were added since the last crawler run. | <pre>object({<br/>    recrawl_behavior = string<br/>  })</pre> | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_role"></a> [role](#input\_role) | The IAM role friendly name (including path without leading slash), or ARN of an IAM role, used by the crawler to access other resources. | `string` | n/a | yes |
| <a name="input_s3_target"></a> [s3\_target](#input\_s3\_target) | List of nested Amazon S3 target arguments. | `list(any)` | `null` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | A cron expression for the schedule. | `string` | `null` | no |
| <a name="input_schema_change_policy"></a> [schema\_change\_policy](#input\_schema\_change\_policy) | Policy for the crawler's update and deletion behavior. | `map(string)` | `null` | no |
| <a name="input_security_configuration"></a> [security\_configuration](#input\_security\_configuration) | The name of Security Configuration to be used by the crawler. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_table_prefix"></a> [table\_prefix](#input\_table\_prefix) | The table prefix used for catalog tables that are created. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Glue crawler ARN |
| <a name="output_id"></a> [id](#output\_id) | Glue crawler ID |
| <a name="output_name"></a> [name](#output\_name) | Glue crawler name |
<!-- markdownlint-restore -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

