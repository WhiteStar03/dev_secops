#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://127.0.0.1:8090/wp-admin/install.php}"
ATTEMPTS="${2:-60}"
SLEEP_SECONDS="${3:-5}"

for ((i=1; i<=ATTEMPTS; i++)); do
  if curl -fsS "${URL}" >/dev/null; then
    echo "WordPress is reachable at ${URL}"
    exit 0
  fi

  echo "Waiting for WordPress (${i}/${ATTEMPTS})..."
  sleep "${SLEEP_SECONDS}"
done

echo "WordPress did not become ready in time: ${URL}" >&2
exit 1
