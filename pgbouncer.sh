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

if [[ -z "${DATABASES_FILE}" ]]; then
  DATABASES_FILE="/etc/pgbouncer/databases.ini"
  touch ${DATABASES_FILE}
fi

pgbouncer_ini_file="/etc/pgbouncer/pgbouncer.ini"
sed -i "s|<DATABASES_FILE>|${DATABASES_FILE}|g" ${pgbouncer_ini_file}

pgbouncer -u nobody ${pgbouncer_ini_file}
