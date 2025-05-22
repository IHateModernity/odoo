#!/bin/sh
set -e

echo "⏳ Waiting for database ${ODOO_DATABASE_HOST}:${ODOO_DATABASE_PORT}"
while ! nc -z "$ODOO_DATABASE_HOST" "$ODOO_DATABASE_PORT" ; do sleep 1; done
echo "✅ DB is up"

##############################################################################
# ОДИН раз перед каждым холодным запуском: удаляем битые web-assets в БД
##############################################################################
psql "postgresql://${ODOO_DATABASE_USER}:${ODOO_DATABASE_PASSWORD}@${ODOO_DATABASE_HOST}:${ODOO_DATABASE_PORT}/${ODOO_DATABASE_NAME}" <<'SQL_EOF'
-- чистим только ассеты
DELETE FROM ir_attachment WHERE url LIKE '/web/assets/%';
UPDATE ir_asset SET active = FALSE;
SQL_EOF
echo "🧹  Assets cache purged"

##############################################################################
# Запускаем Odoo — без --init, без несуществующих путей
##############################################################################
exec odoo \
  --http-port="${PORT}" \
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
  --email-from="${ODOO_EMAIL_FROM}"
