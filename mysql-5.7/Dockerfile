FROM mysql:5.7

# Set global options for mysqld
RUN echo "[mysqld]" >> /etc/mysql/my.cnf \
    # Set port and directories
    && echo "port = 3306" >> /etc/mysql/my.cnf \
    && echo "basedir = /usr" >> /etc/mysql/my.cnf \
    && echo "datadir = /var/lib/mysql" >> /etc/mysql/my.cnf \
    && echo "tmpdir = /tmp" >> /etc/mysql/my.cnf \
    && echo 'sql_mode = "" ' >> /etc/mysql/my.cnf \
    && echo "skip-external-locking" >> /etc/mysql/my.cnf \
    # listen to all interfaces, so php will be able to connect via network
    && echo "bind-address = 0.0.0.0" >> /etc/mysql/my.cnf \
    # A few tweaks for Ubuntu
    && echo "key_buffer_size = 16M" >> /etc/mysql/my.cnf \
    && echo "max_allowed_packet	= 16M" >> /etc/mysql/my.cnf \
    && echo "thread_stack = 192K" >> /etc/mysql/my.cnf \
    && echo "thread_cache_size = 8" >> /etc/mysql/my.cnf \
    && echo "query_cache_limit = 1M" >> /etc/mysql/my.cnf \
    && echo "query_cache_size = 32M" >> /etc/mysql/my.cnf \
    && echo "tmp_table_size = 128m" >> /etc/mysql/my.cnf \
    && echo "max_heap_table_size = 128M" >> /etc/mysql/my.cnf \
    && echo "performance-schema = false"  >> /etc/mysql/my.cnf \
    && echo "table_open_cache = 1024"  >> /etc/mysql/my.cnf \
    && echo "query_cache_type = 1"  >> /etc/mysql/my.cnf \
    && echo "innodb_file_per_table = 0"  >> /etc/mysql/my.cnf \
    && echo "innodb_buffer_pool_size = 250M"  >> /etc/mysql/my.cnf \
    && echo "innodb_buffer_pool_instances = 2"  >> /etc/mysql/my.cnf \
    && echo "innodb_flush_method = O_DIRECT"  >> /etc/mysql/my.cnf \
    && echo "transaction-isolation = READ-COMMITTED"  >> /etc/mysql/my.cnf \
    && echo "innodb_lock_wait_timeout = 50" >> /etc/mysql/my.cnf \
    && echo "innodb_log_buffer_size = 8M" >> /etc/mysql/my.cnf \
    && echo "innodb_flush_log_at_trx_commit = 2" >> /etc/mysql/my.cnf \
    && echo "read_buffer_size = 16M" >> /etc/mysql/my.cnf \
    && echo "innodb_log_file_size = 100M " >> /etc/mysql/my.cnf \
    && echo "innodb_log_buffer_size = 16M" >> /etc/mysql/my.cnf \
    && echo "join_buffer_size = 2M" >> /etc/mysql/my.cnf 
    # The next options will be required when upgrading to mysql 8.0 later
    # Currently, bitrix works better with 5.7
    # Mysql 8.0 uses binary logging by default
    # This drastically decreases the performance of INSERT commands and needs to be removed
    # && echo "skip-log-bin" >> /etc/mysql/my.cnf \
    # By default, mysql 8.0 uses caching_sha2_password 
    # instead of mysql_native_password and bitrix fails to connect
    # Set this option explicitly
    # && echo "default_authentication_plugin= mysql_native_password" >> /etc/mysql/my.cnf