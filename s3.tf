data "template_file" "this" {
  count    = local.script_overridden ? 0 : 1
  template = file("${path.module}/${var.script_template}")
  vars = {
    datalake_bucket        = var.datalake_bucket
    s3_prefix              = var.datalake_prefix
    datalake_format        = var.datalake_format
    optimal_partition_size = var.optimal_partition_size
  }
}

resource "aws_s3_bucket_object" "this" {
  count   = local.script_overridden ? 0 : 1
  bucket  = var.script_s3_bucket
  key     = "${var.script_s3_prefix}/etl-${var.datalake_format}.py"
  content = data.template_file.this[0].rendered
}