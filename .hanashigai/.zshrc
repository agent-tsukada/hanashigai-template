# History
# Use persistent volume if available (vm.sh mounts claude-code-history:/commandhistory),
# otherwise fall back to home directory.
if [[ -d /commandhistory ]]; then
  HISTFILE=/commandhistory/.zsh_history
else
  HISTFILE=~/.zsh_history
fi
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Prompt — dir + git branch
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%~${vcs_info_msg_0_} $ '

# Key bindings (emacs mode)
bindkey -e

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias claude='claude --dangerously-skip-permissions'
alias codex='codex --dangerously-bypass-approvals-and-sandbox'
