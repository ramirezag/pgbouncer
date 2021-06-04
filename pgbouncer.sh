#!/usr/bin/env bash
set -e

pgbouncer_ini_file="/etc/pgbouncer/pgbouncer.ini"
tmp_file="${pgbouncer_ini_file}_tmp"

LISTEN_ADDR=${LISTEN_ADDR:-*}

while read line; do
  echo $line >> ${tmp_file}
  if [[ $line == ";"[a-z]* ]]; then
    OIFS=${IFS}
    IFS='='
    read -a kv <<< "${line}"
    IFS=${OIFS}
    key=`echo ${kv[0]} | sed -e 's/[ ;]//g'`
    var="${key^^}"
    val="${!var}"
    if [[ "${val}" ]]; then
      echo "${key} = ${val}" >> ${tmp_file}
    fi
  fi
done <${pgbouncer_ini_file}

if [[ -z "${DATABASES_INI}" ]]; then
  DATABASES_INI="/etc/pgbouncer/databases.ini"
  touch ${DATABASES_INI}
fi

if [[ -z "${USERS_INI}" ]]; then
  USERS_INI="/etc/pgbouncer/users.ini"
  touch ${USERS_INI}
fi

sed -i "s|<DATABASES_INI>|${DATABASES_INI}|g" ${tmp_file}
sed -i "s|<USERS_INI>|${USERS_INI}|g" ${tmp_file}

mv ${tmp_file} ${pgbouncer_ini_file}

pgbouncer -u pgbouncer ${pgbouncer_ini_file}
