#!/usr/bin/env python3.8

# Import python modules
from datetime import datetime
import math
import sys
import uuid

# Import pyspark modules
from pyspark.context import SparkContext
from pyspark.sql import SQLContext

# Import aws and glue modules
import boto3
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame

# Initialize contexts and session
sc = SparkContext()
sqlContext = SQLContext(sc)
glue_context = GlueContext(sc)
session = glue_context.spark_session
s3 = boto3.resource('s3')

# Determing working folder, it should be of previous month
current_month = datetime.now().month
current_year = datetime.now().year

if current_month == 1:
    working_month = 12
    working_year = current_year - 1
else:
    working_month = f"{current_month - 1:02d}"
    working_year = current_year

# variables
bucket_name = "${datalake_bucket}"
datalake_format = "${datalake_format}"
s3_prefix = "${s3_prefix}"
optimal_partition_size = ${optimal_partition_size}

# Bucket setup
bucket = s3.Bucket(bucket_name)
file_path = f"{s3_prefix}/year={str(working_year)}/month={str(working_month)}"
full_file_path = f"s3://{bucket_name}/{file_path}"

# in MB. Used for partitioning
temp_prefix = f"${s3_prefix}/{str(uuid.uuid4())}"


## EXTRACT ##
# Read data from S3
dynamic_frame_read = glue_context.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={"paths": [full_file_path]},
    format=datalake_format,
    transformation_ctx="dynamic_frame_read"
)

# Calculate size of all files in mb
def get_size(path):
    total_size = 0

    for obj in bucket.objects.filter(Prefix=path):
        total_size = total_size + obj.size

    return round(total_size/1024/1024, 3)


## TRANSFORM ##
folder_size = get_size(file_path)
print('folder-size: ', folder_size, 'mb')

number_of_partitions = math.ceil(folder_size/optimal_partition_size)
print('number_of_partitions: ', number_of_partitions)

dynamic_frame_write = dynamic_frame_read.coalesce(number_of_partitions)
print('Total row count: ', dynamic_frame_write.count())


## LOAD ##
# Write large ${datalake_format} files to a temp folder in S3
glue_context.write_dynamic_frame.from_options(
    frame=dynamic_frame_write,
    connection_type="s3",
    connection_options={
        "path": f"s3://{bucket_name}/{temp_prefix}/"
    },
    format=datalake_format
)

# Delete all small ${datalake_format} files from working folder
for obj in bucket.objects.filter(Prefix=file_path):
    obj.delete()

# copy compacted ${datalake_format} files from temp folder to working folder
for obj in bucket.objects.filter(Prefix=temp_prefix + "/"):
    print(obj.key)
    copy_source = {
        'Bucket': bucket_name,
        'Key': obj.key
    }
    bucket.copy(copy_source, f"{file_path}/{obj.key.split('/')[2]}")

# cleanup temp files
for obj in bucket.objects.filter(Prefix=temp_prefix):
    print(obj.key)
    obj.delete()