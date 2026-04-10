# Install On A New Linux Host

This guide is for setting up `agent-platform-linux` on another Linux machine later.

## What You Need

Install these first:

- Docker Engine
- Docker Compose plugin
- Git
- Bash

Recommended:

- Tailscale for safe remote access

## Clone The Repo

```bash
git clone https://github.com/xdemhdx/agent-platform-linux.git
cd agent-platform-linux
```

## First-Time Setup

```bash
cp .env.example .env
chmod +x scripts/*.sh
./scripts/build.sh
./scripts/up.sh
./scripts/status.sh
```

## Sign In To Azure Separately

Production:

```bash
./scripts/enter-prod.sh
az login
az account show --output table
exit
```

Lab:

```bash
./scripts/enter-lab.sh
az login
az account show --output table
exit
```

Sandbox:

```bash
./scripts/enter-sandbox.sh
az login
az account show --output table
exit
```

Azure CLI state stays isolated in:

- `prod-env/azure`
- `lab-env/azure`
- `sandbox-env/azure`

## Sign In To Codex

```bash
./scripts/enter-prod.sh
codex
```

Codex state stays isolated in:

- `prod-env/codex`
- `lab-env/codex`
- `sandbox-env/codex`

## Daily Use

```bash
./scripts/up.sh
./scripts/status.sh
./scripts/enter-prod.sh
./scripts/down.sh
```

## Move Your Existing State To A New Machine

Back up and restore:

- `prod-env`
- `lab-env`
- `sandbox-env`

Important subfolders:

- `workspace`
- `azure`
- `codex`

If you restore those folders in the same layout, your environment data moves with you.

## Update Later

```bash
git pull
./scripts/down.sh
./scripts/build.sh
./scripts/up.sh
```

## Sanity Check

```bash
./scripts/status.sh
```

You should see:

- all three containers running
- healthy status
- working `az` and `codex`
- the hostnames `PROD-AZ`, `LAB-AZ`, and `SANDBOX-AZ`
