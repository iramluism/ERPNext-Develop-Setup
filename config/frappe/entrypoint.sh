#!/bin/bash


bench config set-common-config -c root_password "mysql"
bench config set-common-config -c admin_password "admin"

bench new-site \
  --force \
  --db-host "${DB_HOST}" \
  --db-name "${DB_NAME}" \
  --db-password "${DB_PASSWORD}" \
  --mariadb-root-password "${DB_ROOT_PASSWORD}" \
  --admin-password "${ADMIN_PASSWORD}" \
"${SITE_NAME}"

bench use "${SITE_NAME}"

bench set-mariadb-host "${DB_HOST}"

apps=$*

for app in $apps; do
    bench install-app "$app"
done

bench set-config developer_mode "${DEVELOPER_MODE}"

bench clear-cache


