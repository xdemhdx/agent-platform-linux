#!/usr/bin/env bash
set -euo pipefail

echo "Opening shell in agent-sandbox..."
exec docker exec -it agent-sandbox bash
