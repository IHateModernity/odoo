#!/bin/sh

set -e

echo Waiting for database...
echo ">> DB_HOST=${ODOO_DATABASE_HOST}"
echo ">> DB_PORT=${ODOO_DATABASE_PORT}"

while ! nc -z ${ODOO_DATABASE_HOST} ${ODOO_DATABASE_PORT} 2>&1; do sleep 1; done; 

echo Database is now available
odoo --version

exec odoo \
    --http-port="${PORT}" \
    --init=all \
    --without-demo=True \
    --proxy-mode \
    --db_host="${ODOO_DATABASE_HOST}" \
    --db_port="${ODOO_DATABASE_PORT}" \
    --db_user="${ODOO_DATABASE_USER}" \
    --db_password="${ODOO_DATABASE_PASSWORD}" \
    --database="${ODOO_DATABASE_NAME}" \
    --smtp="${ODOO_SMTP_HOST}" \
    --smtp-port="${ODOO_SMTP_PORT_NUMBER}" \
    --smtp-user="${ODOO_SMTP_USER}" \
    --smtp-password="${ODOO_SMTP_PASSWORD}" \
    --addons-path=/usr/lib/python3/dist-packages/odoo/addons \
    --email-from="${ODOO_EMAIL_FROM}" 2>&1