#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-fixed}"
SCAN_NAME="${2:-$(date -u +%Y%m%dT%H%M%SZ)}"
WORDPRESS_URL="${WORDPRESS_URL:-http://127.0.0.1:8090}"
OUTPUT_DIR="scans/${PROFILE}"
JSON_OUT="${OUTPUT_DIR}/${SCAN_NAME}.json"
TEXT_OUT="${OUTPUT_DIR}/${SCAN_NAME}.txt"

mkdir -p "${OUTPUT_DIR}"

./scripts/wait-for-wordpress.sh "${WORDPRESS_URL}/wp-admin/install.php"

TOKEN_ARGS=()
if [[ -n "${WPSCAN_API_TOKEN:-}" ]]; then
  TOKEN_ARGS+=(--api-token "${WPSCAN_API_TOKEN}")
fi

set +e
docker run --rm \
  --network host \
  -v "${PWD}/scans:/output" \
  wpscanteam/wpscan:latest \
  --url "${WORDPRESS_URL}" \
  --enumerate u,vp,vt \
  --plugins-detection mixed \
  --force \
  --format json \
  -o "/output/${PROFILE}/${SCAN_NAME}.json" \
  "${TOKEN_ARGS[@]}" 2>&1 | tee "${TEXT_OUT}"
SCAN_EXIT_CODE=${PIPESTATUS[0]}
set -e

echo "WPScan exit code: ${SCAN_EXIT_CODE}"
echo "JSON artifact: ${JSON_OUT}"
echo "Text artifact: ${TEXT_OUT}"

exit 0
