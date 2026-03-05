FROM ubuntu:22.04

ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive

# Base packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg git jq ncurses-term shellcheck tmux zsh sudo \
    iptables iproute2 locales \
    && sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create non-root user with sudo
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /usr/bin/zsh --no-log-init ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Node.js (LTS via nodesource)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Codex (OpenAI CLI)
RUN npm install -g @openai/codex

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Fix ownership of dirs that may have been created as root during installs
# (gh CLI needs write access to ~/.config/gh/)
RUN mkdir -p /home/${USERNAME}/.config /home/${USERNAME}/.local /home/${USERNAME}/.cache \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.config /home/${USERNAME}/.local /home/${USERNAME}/.cache

USER ${USERNAME}
WORKDIR /home/${USERNAME}
ENV XDG_CACHE_HOME=/home/${USERNAME}/.cache
ENV UV_CACHE_DIR=/home/${USERNAME}/.cache/uv
ENV UV_TOOL_DIR=/home/${USERNAME}/.cache/uv/tools
ENV UV_TOOL_BIN_DIR=/home/${USERNAME}/.cache/uv/bin
ENV HF_HOME=/home/${USERNAME}/.cache/huggingface
ENV PATH="/home/${USERNAME}/.cache/uv/bin:/home/${USERNAME}/.local/bin:${PATH}"
COPY .zshrc /home/${USERNAME}/.zshrc

COPY --chmod=755 --chown=${USERNAME}:${USERNAME} container-init.sh /home/${USERNAME}/.local/bin/container-init.sh

# Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash
