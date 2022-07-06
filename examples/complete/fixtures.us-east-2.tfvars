region = "us-east-2"

namespace = "eg"

environment = "ue2"

stage = "test"

name = "glue"

crawler_name = "test-crawler"

cron_schedule = "cron(30 0 1 * ? *)"

datalake_bucket = "test"

datalake_format = "parquet"

datalake_prefix = "example"

glue_version = "2.0"

job_timeout = 2880

max_concurrent_runs = 1

max_retries = 1

number_of_workers = 1

optimal_partition_size = 512

role_arn = ""

script_s3_bucket = "test"

script_s3_prefix = "script-example"

script_template = "etl-py.tpl"

worker_type = "G.1X"
