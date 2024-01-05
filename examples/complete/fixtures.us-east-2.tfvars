region = "us-east-2"

namespace = "eg"

environment = "ue2"

stage = "test"

name = "glue"

glue_version = "2.0"

glue_catalog_table_partition_keys = {
  "test" = {
    name    = "test"
    comment = "test"
    type    = "string"
  }
  "test2" = {
    name = "test2"
    type = "string"
  }
  "test3" = {
    name = "test3"
  }
  "test4" = {
    name    = "test4"
    comment = "test4"
  }
}


glue_catalog_table_partition_index = {
  test   = { 
    index_name = "test", 
    keys = ["test"] 
  },
  test2 = { 
    index_name = "test2",
    keys = ["test2"] 
  }
  test3     = { 
    index_name = "test3_test4",
    keys = ["test3", "test4"]
  }
}
