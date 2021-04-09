# Overview

Minimal docker implementation of [pgbouncer](https://www.pgbouncer.org). The goal is to abstract the building and running of [pgbouncer](https://www.pgbouncer.org) but keep the [usage](https://www.pgbouncer.org/usage.html) very flexible and not reinventing it.

This is the default config used by this image:

```ini
[pgbouncer]
listen_addr = 0.0.0.0
listen_port = 6432
pool_mode = session
```

You can override them along with other [configs](https://github.com/pgbouncer/pgbouncer/blob/master/etc/pgbouncer.ini) by specifying environment variables whose key/name matches to the upper case key of [pgbouncer ini](https://github.com/pgbouncer/pgbouncer/blob/master/etc/pgbouncer.ini).

# Features:

* Built on Alpine with minimal libraries (libevent and c-ares) installed to make pgbouncer work.
* Tuning of configs (except databases) through environmment variables whose key/name is an upper case of the keys in [pgbouncer.ini](https://github.com/pgbouncer/pgbouncer/blob/master/etc/pgbouncer.ini). Eg. To override [pool_mode](https://www.pgbouncer.org/config.html#pool_mode-1) (which is set to session by default), just set the environment variable `POOL_MODE`. See [pgbouncer config](https://www.pgbouncer.org/config.html) for more details.
* Databases file is read if environment variable `DATABASES_FILE` is set
* For flexibility and easy maintenance of this docker image, environment variables `DATABASES_FILE`, `AUTH_TYPE` and`AUTH_FILE` are not marked as required. It's the responsibility of the user to set those variables. Otherwise, an instance of this without those variables would make it unuseable. See [pgbouncer usage](https://www.pgbouncer.org/usage.html) for more details.

# Usage

You can spawn an instance of this docker image by executing `docker run -p 6432:6432 ramirezag/pgbouncer:1.0.0`. However, the instance is not useable since you did not specify any database config. Below are sample setup to make the instance useable.

### Access to destination database will go with single user

1. Create `databases.ini` then add

    ```shell
    [databases]
    template1 = host=localhost port=6432 user=someuser password=somepass dbname=template1 client_encoding=UNICODE datestyle=ISO
    ```

2. Execute

    ```shell
    docker run --rm \
        -v "$(pwd)"/databases.ini:/app/databases.ini
        -e DATABASES_FILE=/app/databases.ini \
        -p 6432:6432 \
        ramirezag/pgbouncer
    ```

3. Connect to pgbouncer - `psql -p 6432 -U someuser template1`


### Use `DATABASES_FILE` to create db info and override some configs

1. Create `databases.ini` then add

    ```shell
    [databases]
    template1 = host=localhost dbname=template1 port=5432
    
    [pgbouncer]
    pool_mode = session
    listen_port = 6432
    listen_addr = localhost
    auth_type = md5
    auth_file = /app/users.txt
    logfile = pgbouncer.log
    pidfile = pgbouncer.pid
    admin_users = adminuser
    stats_users = stat_collector
    ```

2. Create `users.txt` (see [authentication file format](https://www.pgbouncer.org/config.html#authentication-file-format)) then add

    ```shell
    "someuser" "somepassword"
    ```

3. Execute

    ```shell
    docker run --rm \
        -v "$(pwd)"/databases.ini:/app/databases.ini
        -v "$(pwd)"/users.txt:/app/users.txt
        -e DATABASES_FILE=/app/databases.ini \
        -p 6432:6432 \
        ramirezag/pgbouncer
    ```

4. Connect to pgbouncer - `psql -p 6432 -U someuser template1`

### Use `DATABASES_FILE`, `AUTH_TYPE` and`AUTH_FILE` to set db info,

1. Create `databases.ini` then add

    ```shell
    [databases]
    template1 = host=localhost dbname=template1 port=5432
    ```

2. Create `users.txt` then add

    ```shell
    "username1" "somepassword"
    ```

3. Execute

    ```shell
    docker run --rm \
        -v "$(pwd)"/databases.ini:/app/databases.ini
        -v "$(pwd)"/users.txt:/app/users.txt
        -e DATABASES_FILE=/app/databases.ini \
        -e AUTH_TYPE=md5 \
        -e AUTH_FILE=/app/users.txt \
        -p 6432:6432 \
        ramirezag/pgbouncer
    ```

4. Connect to pgbouncer - `psql -p 6432 -U someuser template1`
