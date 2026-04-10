FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG NODE_MAJOR=22
ARG CODEX_NPM_PACKAGE=@openai/codex

SHELL ["/bin/bash", "-lc"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    unzip \
    vim \
    nano \
    dnsutils \
    iputils-ping \
    openssh-client \
    python3 \
    python3-pip \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN npm install -g "${CODEX_NPM_PACKAGE}" \
    && npm cache clean --force

RUN mkdir -p /workspace /root/.azure /root/.codex /etc/agent-platform

RUN cat <<'EOF' >/etc/profile.d/agent-platform.sh
export AGENT_ROLE="${AGENT_ROLE:-AGENT}"
export AGENT_NAME="${AGENT_NAME:-agent}"
export AGENT_COLOR="${AGENT_COLOR:-35}"
if [[ $- == *i* ]]; then
  PS1="\[\e[1;${AGENT_COLOR}m\][${AGENT_ROLE}@\h]\[\e[0m\] \[\e[1;37m\]\w\[\e[0m\]\n# "
fi
EOF

RUN chmod 0644 /etc/profile.d/agent-platform.sh

WORKDIR /workspace

CMD ["bash"]
