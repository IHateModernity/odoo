#!/bin/sh

set -e

echo "Waiting for database ${ODOO_DATABASE_HOST}:${ODOO_DATABASE_PORT} …"
while ! nc -z "$ODOO_DATABASE_HOST" "$ODOO_DATABASE_PORT" 2>&1; do sleep 1; done
echo "Database is now available"

ODOO_INIT="--init=custom_fetchmail_no_seen"


exec odoo \
    --http-port="${PORT}" \
    $ODOO_INIT \
    --without-demo=True \
    --proxy-mode \
    --workers=2 \
    --max-cron-threads=1 \
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