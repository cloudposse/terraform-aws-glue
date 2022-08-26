#  Copyright 2016-2020 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#  SPDX-License-Identifier: MIT-0

from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from pyspark.context import SparkContext
from pyspark.sql.functions import udf
from pyspark.sql.types import StringType

glueContext = GlueContext(SparkContext.getOrCreate())

# Data Catalog: database and table name
db_name = "payments"
tbl_name = "medicare"

# S3 location for output
output_dir = "s3://eg-ue2-test-glue-destination/medicare_parquet"

# Read data into a DynamicFrame using the Data Catalog metadata
medicare_dyf = glueContext.create_dynamic_frame.from_catalog(database=db_name, table_name=tbl_name)

# The `provider id` field will be choice between long and string

# Cast choices into integers, those values that cannot cast result in null
medicare_res = medicare_dyf.resolveChoice(specs=[('provider id', 'cast:long')])

# Remove erroneous records
medicare_df = medicare_res.toDF()
medicare_df = medicare_df.where("`provider id` is NOT NULL")

# Apply a lambda to remove the '$'
chop_f = udf(lambda x: x[1:], StringType())
medicare_df = medicare_df.withColumn("ACC", chop_f(medicare_df["average covered charges"])).withColumn("ATP", chop_f(medicare_df["average total payments"])).withColumn("AMP", chop_f(
    medicare_df["average medicare payments"]))

# Turn it back to a dynamic frame
medicare_tmp = DynamicFrame.fromDF(medicare_df, glueContext, "nested")

# Rename, cast, and nest with apply_mapping
medicare_nest = medicare_tmp.apply_mapping([('drg definition', 'string', 'drg', 'string'),
                                            ('provider id', 'long', 'provider.id', 'long'),
                                            ('provider name', 'string', 'provider.name', 'string'),
                                            ('provider city', 'string', 'provider.city', 'string'),
                                            ('provider state', 'string', 'provider.state', 'string'),
                                            ('provider zip code', 'long', 'provider.zip', 'long'),
                                            ('hospital referral region description', 'string', 'rr', 'string'),
                                            ('ACC', 'string', 'charges.covered', 'double'),
                                            ('ATP', 'string', 'charges.total_pay', 'double'),
                                            ('AMP', 'string', 'charges.medicare_pay', 'double')])

# Write it out in Parquet
glueContext.write_dynamic_frame.from_options(frame=medicare_nest, connection_type="s3", connection_options={"path": output_dir}, format="parquet")
