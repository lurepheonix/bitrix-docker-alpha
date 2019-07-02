FROM mysql:5.7

# Set global options for mysqld
RUN echo "[mysqld]" >> /etc/mysql/my.cnf \
    # Set port and directories
    && echo "port = 3306" >> /etc/mysql/my.cnf \
    && echo "basedir = /usr" >> /etc/mysql/my.cnf \
    && echo "datadir = /var/lib/mysql" >> /etc/mysql/my.cnf \
    && echo "tmpdir = /tmp" >> /etc/mysql/my.cnf \
    && echo "skip-external-locking" >> /etc/mysql/my.cnf \
    # listen to all interfaces, so php will be able to connect via network
    && echo "bind-address = 0.0.0.0" >> /etc/mysql/my.cnf \
    # A few tweaks for Ubuntu
    && echo "key_buffer_size = 16M" >> /etc/mysql/my.cnf \
    && echo "max_allowed_packet	= 16M" >> /etc/mysql/my.cnf \
    && echo "thread_stack = 192K" >> /etc/mysql/my.cnf \
    && echo "thread_cache_size = 8" >> /etc/mysql/my.cnf \
    && echo "query_cache_limit = 1M" >> /etc/mysql/my.cnf \
    && echo "query_cache_size = 16M" >> /etc/mysql/my.cnf \
    && echo "sql_mode=" >> /etc/mysql/my.cnf
    # The next options will be required when upgrading to mysql 8.0 later
    # Currently, bitrix works better with 5.7
    # Mysql 8.0 uses binary logging by default
    # This drastically decreases the performance of INSERT commands and needs to be removed
    # && echo "skip-log-bin" >> /etc/mysql/my.cnf \
    # By default, mysql 8.0 uses caching_sha2_password 
    # instead of mysql_native_password and bitrix fails to connect
    # Set this option explicitly
    # && echo "default_authentication_plugin= mysql_native_password" >> /etc/mysql/my.cnf