# Overview

Minimal docker implementation of [pgbouncer](https://www.pgbouncer.org). The goal is to abstract the building and running of [pgbouncer](https://www.pgbouncer.org) but keep the [usage](https://www.pgbouncer.org/usage.html) very flexible and not reinventing it. 

# Features:

* Built on Alpine with minimal libraries (libevent and c-ares) installed to make pgbouncer work.
* Tuning of configs (except databases) through environmment variables whose key/name is an upper case of the keys in [pgbouncer.ini](https://github.com/pgbouncer/pgbouncer/blob/master/etc/pgbouncer.ini). Eg. To override [pool_mode](https://www.pgbouncer.org/config.html#pool_mode-1) (which is set to session by default), just set the environment variable `POOL_MODE`. See [pgbouncer config](https://www.pgbouncer.org/config.html) for more details.
* Databases file is read if environment variable `DATABASES_FILE` is set
* For flexibility and easy maintenance of this docker image, environment variables `DATABASES_FILE`, `AUTH_TYPE` and`AUTH_FILE` are not marked as required. It's the responsibility of the user to set those variables. Otherwise, an instance of this without those variables would make it unuseable. See [pgbouncer usage](https://www.pgbouncer.org/usage.html) for more details.

# Usage

### Access to destination database will go with single user

1. Create `databases.ini` then add

    ```shell
    [databases]
    forcedb = host=localhost port=300 user=baz password=foo client_encoding=UNICODE datestyle=ISO
    ```

2. Execute

    ```shell
    docker run --rm \
        -v "$(pwd)"/databases.ini:/app/databases.ini
        -e DATABASES_FILE=/app/databases.ini \
        -p 5432:5432 \
        ramirezag/pgbouncer
    ```

### Use `DATABASES_FILE` to create db info and override some configs

1. Create `databases.ini` then add

    ```shell
    [databases]
    template1 = host=localhost dbname=template1 auth_user=someuser
    
    [pgbouncer]
    pool_mode = session
    listen_port = 6432
    listen_addr = localhost
    auth_type = md5
    auth_file = /app/users.txt
    logfile = pgbouncer.log
    pidfile = pgbouncer.pid
    admin_users = someuser
    stats_users = stat_collector
    ```

2. Create `users.txt` (see [authentication file format](https://www.pgbouncer.org/config.html#authentication-file-format)) then add

    ```shell
    "username1" "password"
    ```

3. Execute
   
    ```shell
    docker run --rm \
        -v "$(pwd)"/databases.ini:/app/databases.ini
        -v "$(pwd)"/users.txt:/app/users.txt
        -e DATABASES_FILE=/app/databases.ini \
        -p 5432:5432 \
        ramirezag/pgbouncer
    ```

### Use `DATABASES_FILE`, `AUTH_TYPE` and`AUTH_FILE` to create db info and override some configs

1. Create `databases.ini` then add

    ```shell
    [databases]
    template1 = host=localhost dbname=template1 auth_user=someuser
    ```

2. Create `users.txt` then add

    ```shell
    "username1" "password"
    ```

3. Execute
   
    ```shell
    docker run --rm \
        -v "$(pwd)"/databases.ini:/app/databases.ini
        -v "$(pwd)"/users.txt:/app/users.txt
        -e DATABASES_FILE=/app/databases.ini \
        -e AUTH_TYPE=md5 \
        -e AUTH_FILE=/app/users.txt \
        -p 5432:5432 \
        ramirezag/pgbouncer
    ```
