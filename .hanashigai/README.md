# Container Image for Claude Code Sandbox

The Dockerfile in this directory is used to build your execution environment. By editing that Dockerfile, you can make permanent changes to your execution environment.

## Build arguments

| Arg | Default | Description |
|-----|---------|-------------|
| `USERNAME` | `node` | Non-root user inside the container |
| `USER_UID` | `1000` | UID (overridden at build time to match VM host user) |
| `USER_GID` | `1000` | GID (overridden at build time to match VM host user) |

The builder script passes `--build-arg USER_UID="$(id -u)" --build-arg USER_GID="$(id -g)"` so that file permissions on the bind-mounted `/workspace` volume align with the host.

## `--no-log-init` on `useradd`

GCP OS Login assigns UIDs in the `2000000000+` range. Without `--no-log-init`, `useradd` creates `/var/log/lastlog` as a sparse file sized proportional to the UID, which can appear as hundreds of GB and cause Docker build failures or extremely slow layer creation. **Do not remove this flag.**

## Installed tools

| Package | Reason |
|---------|--------|
| `git`, `curl`, `jq` | Core dev tools |
| `tmux` | Session persistence across SSH disconnects |
| `zsh` | Default shell |
| `shellcheck` | Linting bash scripts |
| `iptables`, `iproute2` | Container-level firewall |
| `sudo` | Required for iptables; user has passwordless sudo |
| Node.js (LTS) | Runtime for Claude Code |
| GitHub CLI (`gh`) | GitHub auth and credential helper for git |
| Claude Code | Installed via `claude.ai/install.sh` |
| Codex | Installed via `npm install -g @openai/codex` |

## Volumes

| Mount | Target | Persistence |
|-------|--------|-------------|
| `${REPO_DIR}` (bind) | `/workspace` | Lives on VM disk |
| `claude-code-config` (named volume) | `/home/node/.claude` | Survives container recreation |
| `shell-history` (named volume) | `/commandhistory` | Survives container recreation |
| `codex-config` (named volume) | `/home/node/.codex` | Survives container recreation |
| `tool-cache` (named volume) | `/home/node/.cache` | Survives container recreation |

## Capabilities

`--cap-add=NET_ADMIN --cap-add=NET_RAW` are required for `init-firewall.sh` (iptables-based domain allowlist in strict firewall mode).

## Customization

- Add packages: insert a `RUN apt-get install ...` line before the `USER` directive.
- The `USER` directive must remain after all root-level installs.
- The `chown` block before `USER` fixes ownership of `~/.config` and `~/.local` -- keep it after any installs that might create those directories as root.
