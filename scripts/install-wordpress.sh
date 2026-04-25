#!/usr/bin/env bash
set -euo pipefail

WORDPRESS_URL="${WORDPRESS_URL:-http://127.0.0.1:8090}"
INSTALL_URL="${WORDPRESS_URL}/wp-admin/install.php"

SITE_TITLE="${WP_SITE_TITLE:-DevSecOps Lab}"
ADMIN_USER="${WP_ADMIN_USER:-admin}"
ADMIN_PASSWORD="${WP_ADMIN_PASSWORD:-AdminPass123!}"
ADMIN_EMAIL="${WP_ADMIN_EMAIL:-admin@example.com}"

INSTALL_PAGE="$(curl -fsS "${INSTALL_URL}")"

if [[ "${INSTALL_PAGE}" != *'id="setup"'* ]]; then
  echo "WordPress is already configured."
  exit 0
fi

curl -fsS -X POST "${INSTALL_URL}?step=2" \
  --data-urlencode "weblog_title=${SITE_TITLE}" \
  --data-urlencode "user_name=${ADMIN_USER}" \
  --data-urlencode "admin_password=${ADMIN_PASSWORD}" \
  --data-urlencode "admin_password2=${ADMIN_PASSWORD}" \
  --data-urlencode "pw_weak=1" \
  --data-urlencode "admin_email=${ADMIN_EMAIL}" \
  --data-urlencode "blog_public=0" \
  --data-urlencode "Submit=Install WordPress" \
  --data-urlencode "language=" >/tmp/wordpress-install-response.html

if grep -q "Success!" /tmp/wordpress-install-response.html; then
  echo "WordPress installation completed for ${WORDPRESS_URL}"
  exit 0
fi

echo "WordPress installation did not return a success page." >&2
sed -n '1,120p' /tmp/wordpress-install-response.html >&2
exit 1
