# Agent Platform Linux

This project gives you three persistent Dockerized terminal environments on a Linux host for running isolated Codex and Azure CLI workflows in parallel.

- `agent-prod` for production or work Azure activity
- `agent-lab` for testing and lab work
- `agent-sandbox` for experiments and safe throwaway testing

Each container has its own mounted workspace, its own Azure CLI state folder, and its own Codex state folder. You manage the whole stack with Docker Compose and Bash scripts.

For moving this setup to another Linux machine later, use [`INSTALL-NEW-PC.md`](INSTALL-NEW-PC.md).

## Architecture

The platform uses one shared base image and three services in [`docker-compose.yml`](docker-compose.yml):

- `agent-prod` with hostname `PROD-AZ`
- `agent-lab` with hostname `LAB-AZ`
- `agent-sandbox` with hostname `SANDBOX-AZ`

All three containers join the custom Docker bridge network `agent-net`. Docker automatically assigns internal IPs, but you should use the container names instead of memorizing addresses.

The image defined in [`base/Dockerfile`](base/Dockerfile) includes:

- `bubblewrap`
- Ubuntu 24.04
- `curl`, `git`, `jq`, `unzip`, `vim`, `nano`, `dnsutils`, `iputils-ping`, `openssh-client`, `python3`, `python3-pip`
- Node.js and npm
- Azure CLI
- Codex CLI installed globally so `codex` works directly

## Why The Environments Are Isolated

Each service mounts a different set of host folders:

- `./prod-env/workspace` -> `/workspace`
- `./prod-env/azure` -> `/root/.azure`
- `./prod-env/codex` -> `/root/.codex`
- `./lab-env/workspace` -> `/workspace`
- `./lab-env/azure` -> `/root/.azure`
- `./lab-env/codex` -> `/root/.codex`
- `./sandbox-env/workspace` -> `/workspace`
- `./sandbox-env/azure` -> `/root/.azure`
- `./sandbox-env/codex` -> `/root/.codex`

That separation matters because:

- Azure CLI stores login tokens and local CLI state in `/root/.azure`
- Codex stores local config and session state in `/root/.codex`
- your repos and files live in `/workspace`

Because each container mounts different folders, each environment keeps its own Azure login and Codex context.

## Folder Layout

```text
agent-platform-linux/
|-- docker-compose.yml
|-- .env.example
|-- .gitignore
|-- README.md
|-- INSTALL-NEW-PC.md
|-- scripts/
|   |-- build.sh
|   |-- up.sh
|   |-- down.sh
|   |-- enter-prod.sh
|   |-- enter-lab.sh
|   |-- enter-sandbox.sh
|   |-- logs.sh
|   `-- status.sh
|-- base/
|   `-- Dockerfile
|-- prod-env/
|   |-- workspace/
|   |-- azure/
|   `-- codex/
|-- lab-env/
|   |-- workspace/
|   |-- azure/
|   `-- codex/
`-- sandbox-env/
    |-- workspace/
    |-- azure/
    `-- codex/
```

## Linux Host Requirements

Assumptions for this setup:

- Linux host with Docker Engine and Docker Compose plugin installed
- Bash available
- your user can run `docker` commands

Optional but recommended:

- Git
- Tailscale for safe remote access to the Linux host

## Build And Start

From your shell:

```bash
cd ./agent-platform-linux
cp .env.example .env
chmod +x scripts/*.sh
./scripts/build.sh
./scripts/up.sh
./scripts/status.sh
```

If you do not want a `.env` file yet, you can skip that copy step because the compose file already has sensible defaults.

## Azure CLI State And Separate Logins

Azure CLI state is stored persistently in:

- [`prod-env/azure`](prod-env/azure)
- [`lab-env/azure`](lab-env/azure)
- [`sandbox-env/azure`](sandbox-env/azure)

Sign in separately for each environment:

```bash
./scripts/enter-prod.sh
az login
az account show
exit
```

```bash
./scripts/enter-lab.sh
az login
az account show
exit
```

```bash
./scripts/enter-sandbox.sh
az login
az account show
exit
```

If you use different subscriptions, set them independently inside each container with `az account set --subscription "<name-or-id>"`.

## Codex State And Separate Config

Codex state is stored persistently in:

- [`prod-env/codex`](prod-env/codex)
- [`lab-env/codex`](lab-env/codex)
- [`sandbox-env/codex`](sandbox-env/codex)

Inside any container you can run:

```bash
codex
```

Authentication options:

- ChatGPT sign-in flow
- API key flow by exporting `OPENAI_API_KEY` inside the container session

Example:

```bash
./scripts/enter-prod.sh
codex
```

## Bubblewrap Note

The image installs system `bubblewrap` so Codex can use the host package directly inside the container instead of falling back to its vendored copy.

## Managing The Stack

Use the included Bash scripts:

- [`scripts/build.sh`](scripts/build.sh) builds the image
- [`scripts/up.sh`](scripts/up.sh) starts all containers
- [`scripts/down.sh`](scripts/down.sh) stops the containers
- [`scripts/enter-prod.sh`](scripts/enter-prod.sh) opens a shell in `agent-prod`
- [`scripts/enter-lab.sh`](scripts/enter-lab.sh) opens a shell in `agent-lab`
- [`scripts/enter-sandbox.sh`](scripts/enter-sandbox.sh) opens a shell in `agent-sandbox`
- [`scripts/logs.sh`](scripts/logs.sh) shows compose logs
- [`scripts/status.sh`](scripts/status.sh) shows compose status and basic tool checks

## Updating The Image Later

When you want to refresh the base environment:

```bash
cd ./agent-platform-linux
./scripts/down.sh
./scripts/build.sh
./scripts/up.sh
```

For a completely fresh rebuild:

```bash
docker compose build --no-cache
```

## Backing Up Persistent Data

Back up these folders:

- [`prod-env`](prod-env)
- [`lab-env`](lab-env)
- [`sandbox-env`](sandbox-env)

At minimum, preserve:

- each `workspace/` directory
- each `azure/` directory
- each `codex/` directory

## Remote Access Guidance

If you need to access the Linux host remotely, avoid exposing SSH directly to the public internet unless you have a hardened setup. Tailscale is the safer default: install it on the host, join the machine to your tailnet, and connect over Tailscale instead of direct port forwarding.

## Networking Notes

Each container gets its own internal Docker IP automatically on `agent-net`. Those IPs can change, so use:

- `agent-prod`
- `agent-lab`
- `agent-sandbox`

## Shell Prompt Safety

Each container gets a bold environment-specific shell prompt:

- `PROD` uses red
- `LAB` uses yellow
- `SANDBOX` uses cyan

The prompt also includes the hostname so you can tell instantly which environment you are in.

## Exact First Commands

```bash
cd ./agent-platform-linux
cp .env.example .env
chmod +x scripts/*.sh
./scripts/build.sh
./scripts/up.sh
./scripts/status.sh
```

## Exact Commands To Enter Each Environment

```bash
cd ./agent-platform-linux
./scripts/enter-prod.sh
```

```bash
cd ./agent-platform-linux
./scripts/enter-lab.sh
```

```bash
cd ./agent-platform-linux
./scripts/enter-sandbox.sh
```

## Exact Commands To Test Codex

Inside any container:

```bash
codex --help
codex
```

## Exact Commands To Verify Azure Account Isolation

Run this in each container:

```bash
hostname
az account show --query "{name:name, subscriptionId:id, tenantId:tenantId}" --output table
ls -la /root/.azure
```

## Sanity Check

After startup:

1. `./scripts/status.sh` should show all three containers as running and healthy
2. `./scripts/enter-prod.sh` should show a red `PROD` prompt and `hostname` should return `PROD-AZ`
3. `./scripts/enter-lab.sh` should show `LAB-AZ`
4. `./scripts/enter-sandbox.sh` should show `SANDBOX-AZ`
5. `codex --help` should work in each container
6. `az version` should work in each container
