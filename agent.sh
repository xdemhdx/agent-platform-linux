#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_action() {
  local script_name="$1"
  "${ROOT_DIR}/scripts/${script_name}"
}

pause_after() {
  echo
  read -r -p "Press Enter to return to the menu..."
}

print_header() {
  clear
  cat <<'EOF'
Agent Platform Linux
Interactive control menu for prod, lab, and sandbox containers
EOF
  echo
}

print_menu() {
  cat <<'EOF'
1. Build image
   Build or rebuild the shared Docker image used by all agent containers.

2. Start all containers
   Start prod, lab, and sandbox in the background with docker compose.

3. Stop all containers
   Stop and remove the running containers while keeping persistent data folders.

4. Status
   Show container state, health, hostname, Azure CLI version, and Codex version.

5. Enter prod
   Open an interactive shell inside the production container.

6. Enter lab
   Open an interactive shell inside the lab container.

7. Enter sandbox
   Open an interactive shell inside the sandbox container.

8. Logs
   Show docker compose logs for the whole stack.

9. Exit
   Leave the interactive launcher.
EOF
  echo
}

main_loop() {
  while true; do
    print_header
    print_menu
    read -r -p "Choose an option [1-9]: " choice
    echo

    case "${choice}" in
      1)
        run_action "build.sh"
        pause_after
        ;;
      2)
        run_action "up.sh"
        pause_after
        ;;
      3)
        run_action "down.sh"
        pause_after
        ;;
      4)
        run_action "status.sh"
        pause_after
        ;;
      5)
        run_action "enter-prod.sh"
        ;;
      6)
        run_action "enter-lab.sh"
        ;;
      7)
        run_action "enter-sandbox.sh"
        ;;
      8)
        run_action "logs.sh"
        pause_after
        ;;
      9)
        echo "Exiting."
        exit 0
        ;;
      *)
        echo "Invalid selection. Choose a number from 1 to 9."
        pause_after
        ;;
    esac
  done
}

main_loop
