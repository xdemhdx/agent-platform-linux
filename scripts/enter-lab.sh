#!/usr/bin/env bash
set -euo pipefail

echo "Opening shell in agent-lab..."
exec docker exec -it agent-lab bash
