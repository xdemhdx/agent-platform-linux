#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Docker Compose status"
docker compose -f "${ROOT_DIR}/docker-compose.yml" ps

echo
echo "Basic container verification"

containers=(agent-prod agent-lab agent-sandbox)
for container in "${containers[@]}"; do
  echo
  echo "[$container]"

  if ! docker inspect "$container" >/dev/null 2>&1; then
    echo "container not created"
    continue
  fi

  state="$(docker inspect --format '{{.State.Status}}|{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' "$container")"
  status_part="${state%%|*}"
  health_part="${state#*|}"

  echo "state:  ${status_part}"
  echo "health: ${health_part}"

  if [[ "${status_part}" == "running" ]]; then
    hostname_value="$(docker exec "$container" hostname)"
    az_version="$(docker exec "$container" az version --output json | jq -r '."azure-cli"')"
    codex_version="$(docker exec "$container" codex --version)"

    echo "hostname: ${hostname_value}"
    echo "az:       ${az_version}"
    echo "codex:    ${codex_version}"
  fi
done
