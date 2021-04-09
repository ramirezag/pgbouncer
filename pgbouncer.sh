#!/usr/bin/env bash
set -e

overrides_ini=/etc/pgbouncer/overrides.ini
tmp_file="${overrides_ini}_tmp"

while read line; do
  echo $line >> ${tmp_file}
  if [[ $line == ";"[a-z]* ]]; then
    OIFS=IFS
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
done </etc/pgbouncer/overrides.ini

mv ${tmp_file} ${overrides_ini}

if [[ "${DATABASES_FILE}" ]]; then
  cp ${DATABASES_FILE} /etc/pgbouncer/databases.ini
else
  touch /etc/pgbouncer/databases.ini
fi

pgbouncer -u nobody /etc/pgbouncer/pgbouncer.ini
