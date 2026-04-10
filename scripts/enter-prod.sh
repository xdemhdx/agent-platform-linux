#!/usr/bin/env bash
set -euo pipefail

echo "Opening shell in agent-prod..."
exec docker exec -it agent-prod bash
