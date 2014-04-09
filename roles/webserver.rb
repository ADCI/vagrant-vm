name "webserver"
description "Default settings for web server."

run_list(
  "recipe[apt]",
  "recipe[git]",
  "recipe[phpapp]",
  "recipe[drush]",
  "recipe[phing]",
  "recipe[codesniffer]",
  "recipe[phpmd]",
  "recipe[phpcpd]",
  # Use following recipes when you really need it.
  #"recipe[redis::source]",
  #"recipe[jenkins::java]",
  #"recipe[jenkins::master]",
  #"recipe[firefox]",
  #"recipe[xvfb]",
  #"recipe[jenkins_plugins]",
  # Jmeter requires Jave VM to run which can be installed by uncommenting "recipe[jenkins::java]" above.
  #"recipe[jmeter]",
)

default_attributes(
  "project" => {
    "sites" => {
      "site" => 4567,
#      "another_site" => 4568,
    }
  },

  "redis" => {
    "source" => {
      "version" => "2.6.7",
      "timeout" => "0",
    }
  },

  "mysql" => {
    "server_root_password" => "root",
    "server_debian_password" => "root",
    "server_repl_password" => "root",
    "tunable" => {
      # According to MySQL docs this parameter is most important for InnoDB tables.
      # They suggest to set it to 80% of available to MySQL memory for dedicated servers.
      "innodb_buffer_pool_size" => "512M",
      "table_open_cache" => "512",
      "innodb_additional_mem_pool_size" => "32M",
      "innodb_log_buffer_size" => "16M",
      # InnoDB tables ignore this parameter but according to MySQL docs it still used
      # for temp tables.
      "key_buffer_size" => "32M",
      # Number of open tables for all threads.
      "table_cache" => "512",
      "max_tmp_tables" => "512",
      "thread_cache_size" => "16",
      "join_buffer_size" => "512K",
      "innodb_io_capacity" => "2000",

      # How much of concurrent thread can access InnoDB at the same time.
      # Infinite values for different MySQL versions:
      # 8 for < 5.0.8
      # 20 for 5.0.8 to 5.0.18
      # 0 for 5.0.19 and 5.0.20
      # 8 from 5.0.21
      "innodb_thread_concurrency" => "8",
      "innodb_commit_concurrency" => "8",
      "innodb_read_io_threads" => "8",
      # Flush log to disc is time consuming operation
      # 1 - write and flush to disc at every commit (default)
      # 2 - write at every commit but flush to disc at every second
      # 0 - write and flush every second
      "innodb_flush_log_at_trx_commit" => "0",

      "innodb_open_files" => "4000",
      "net_buffer_length" => "128K",

      "query_cache_limit" => "4M",
      "query_cache_size" => "64M",
    }
  }
)
