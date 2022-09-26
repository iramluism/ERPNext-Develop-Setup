#!/bin/bash

init(){

    sudo chown frappe:frappe -R .

    bench init --version=version-14 --skip-redis-config-generation --no-procfile --verbose --python python3.10 --ignore-exist .

    bench get-app payments

    bench get-app --branch version-14 --resolve-deps erpnext

    bench get-app hrms

    for app in ${CUSTOM_APPS} ; do
        bench get-app --branch develop "$app"
    done

    chown frappe:frappe -R .

    bench setup requirements

    bench build --production --verbose --hard-link

    bench set-config -g db_host mariadb
    bench set-config -g redis_cache redis://redis-cache:6379
    bench set-config -g redis_queue redis://redis-queue:6379
    bench set-config -g redis_socketio redis://redis-socketio:6379

    bench config set-common-config -c root_password "mysql"
    bench config set-common-config -c admin_password "admin"

    bench new-site \
      --force \
      --db-host mariadb \
      --db-name "${DB_NAME}" \
      --db-password "${DB_PASSWORD}" \
      --mariadb-root-password "${DB_ROOT_PASSWORD}" \
      --admin-password "${ADMIN_PASSWORD}" \
    "${SITE_NAME}"

    bench use "${SITE_NAME}"

    bench set-mariadb-host "${DB_HOST}"

    # shellcheck disable=SC2013
    for app in $( cat sites/apps.txt ); do
        bench install-app "$app"
    done

    bench set-config developer_mode "${DEVELOPER_MODE}"

    bench clear-cache
}

if [ ! -d apps ]
then
  init
fi

if [ "$DEV_SERVER" = 1 ]
then
  bench server --port 8000
fi


