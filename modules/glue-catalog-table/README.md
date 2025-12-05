# glue-catalog-table

Terraform module to provision AWS Glue Catalog Tables.

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

module "glue_catalog_database" {
  source = "cloudposse/glue/aws//modules/glue-catalog-database"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  catalog_database_name        = "analytics"
  catalog_database_description = "Glue Catalog database using data located in an S3 bucket"
  location_uri                 = format("s3://%s", module.s3_bucket_source.bucket_id)

  context = module.this.context
}

module "glue_catalog_table" {
  source = "cloudposse/glue/aws//modules/glue-catalog-table"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  catalog_table_name        = "geo"
  catalog_table_description = "region/state/county Glue Catalog table"
  database_name             = module.glue_catalog_database.name

  parameters = {
    "lakeformation.aso.status" = true
    "classification"           = "parquet"
  }

  storage_descriptor = {
    # List of reducer grouping columns, clustering columns, and bucketing columns in the table
    bucket_columns = null
    # Configuration block for columns in the table
    columns = [
      {
        name = "county",
        type = "string"
      },
      {
        name = "state",
        type = "string"
      },
      {
        name = "region",
        type = "string"
      }
    ]
    # Whether the data in the table is compressed
    compressed = false
    # Input format: SequenceFileInputFormat (binary), or TextInputFormat, or a custom format
    input_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    # Physical location of the table. By default this takes the form of the warehouse location, followed by the database location in the warehouse, followed by the table name
    location = format("s3://%s/geo",  module.s3_bucket_source.bucket_id)
    #  Must be specified if the table contains any dimension columns
    number_of_buckets = 0
    # Output format: SequenceFileOutputFormat (binary), or IgnoreKeyTextOutputFormat, or a custom format
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    # Configuration block for serialization and deserialization ("SerDe") information
    ser_de_info = {
      # Map of initialization parameters for the SerDe, in key-value form
      parameters = {
        "serialization.format" = "1"
      }
      # Usually the class that implements the SerDe. An example is org.apache.hadoop.hive.serde2.columnar.ColumnarSerDe
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }
    # Whether the table data is stored in subdirectories
    stored_as_sub_directories = false
  }

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
| [aws_glue_catalog_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_catalog_id"></a> [catalog\_id](#input\_catalog\_id) | ID of the Glue Catalog and database to create the table in. If omitted, this defaults to the AWS Account ID plus the database name. | `string` | `null` | no |
| <a name="input_catalog_table_description"></a> [catalog\_table\_description](#input\_catalog\_table\_description) | Description of the table. | `string` | `null` | no |
| <a name="input_catalog_table_name"></a> [catalog\_table\_name](#input\_catalog\_table\_name) | Name of the table. | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the metadata database where the table metadata resides. | `string` | n/a | yes |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner of the table. | `string` | `null` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Properties associated with this table, as a map of key-value pairs. | `map(string)` | `null` | no |
| <a name="input_partition_index"></a> [partition\_index](#input\_partition\_index) | Configuration block for a maximum of 3 partition indexes. | <pre>object({<br/>    index_name = string<br/>    keys       = list(string)<br/>  })</pre> | `null` | no |
| <a name="input_partition_keys"></a> [partition\_keys](#input\_partition\_keys) | Configuration block of columns by which the table is partitioned. Only primitive types are supported as partition keys. | `map(any)` | `{}` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_retention"></a> [retention](#input\_retention) | Retention time for the table. | `number` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_storage_descriptor"></a> [storage\_descriptor](#input\_storage\_descriptor) | Configuration block for information about the physical storage of this table. | `any` | `null` | no |
| <a name="input_table_type"></a> [table\_type](#input\_table\_type) | Type of this table (`EXTERNAL_TABLE`, `VIRTUAL_VIEW`, etc.). While optional, some Athena DDL queries such as `ALTER TABLE` and `SHOW CREATE TABLE` will fail if this argument is empty. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_target_table"></a> [target\_table](#input\_target\_table) | Configuration block of a target table for resource linking. | <pre>object({<br/>    catalog_id    = string<br/>    database_name = string<br/>    name          = string<br/>  })</pre> | `null` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_view_expanded_text"></a> [view\_expanded\_text](#input\_view\_expanded\_text) | If the table is a view, the expanded text of the view; otherwise null. | `string` | `null` | no |
| <a name="input_view_original_text"></a> [view\_original\_text](#input\_view\_original\_text) | If the table is a view, the original text of the view; otherwise null. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Glue catalog table ARN |
| <a name="output_id"></a> [id](#output\_id) | Glue catalog table ID |
| <a name="output_name"></a> [name](#output\_name) | Glue catalog table name |
<!-- markdownlint-restore -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

