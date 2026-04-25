#!/usr/bin/env bash
set -euo pipefail

docker run --rm \
  -v "${PWD}:/data" \
  --workdir /data \
  pandoc/latex:3.1 \
  report/report.md \
  -o report/report.pdf

echo "Generated report/report.pdf"
