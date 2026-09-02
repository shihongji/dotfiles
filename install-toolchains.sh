#!/usr/bin/env bash
# Language toolchains + Claude Code.
#
# Kept OUT of install.sh because none of these come from Homebrew: each ships
# its own installer and its own version manager, and each wants to own its
# directory. Running this twice is safe — every step is skipped if present.
#
#   ./install-toolchains.sh              # everything
#   ./install-toolchains.sh rust node    # only the named ones
#
# Available: java scala python rust node claude
set -euo pipefail

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  ! \033[0m%s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

WANT=("$@")
want() {
  [ ${#WANT[@]} -eq 0 ] && return 0
  for w in "${WANT[@]}"; do [ "$w" = "$1" ] && return 0; done
  return 1
}

# Homebrew may not be on PATH yet in this shell (it lives outside the default
# PATH on both Apple Silicon and Intel) — same guard as install.sh.
if ! have brew; then
  for p in /opt/homebrew /usr/local; do
    [ -x "$p/bin/brew" ] && eval "$("$p/bin/brew" shellenv)" && break
  done
fi

# --- Java --------------------------------------------------------------------
# Temurin 25 (current) via cask. The Brewfile's `openjdk` is enough to RUN a
# JAR; this adds a full, java_home-registered JDK for actual development.
if want java; then
  say "Java"
  if /usr/libexec/java_home >/dev/null 2>&1; then
    echo "    already: $(/usr/libexec/java_home)"
  else
    brew install --cask temurin || warn "temurin install failed"
  fi
fi

# --- Scala -------------------------------------------------------------------
# Coursier is the Scala toolchain manager; `cs setup` installs scala, scalac,
# sbt, scalafmt, ammonite, bloop and metals in one go.
if want scala; then
  say "Scala"
  if have cs || have coursier; then
    echo "    coursier already installed"
  else
    brew install coursier || warn "coursier install failed"
  fi
  if have cs && [ ! -x "$HOME/Library/Application Support/Coursier/bin/scala" ]; then
    cs setup --yes || warn "cs setup failed"
  else
    echo "    scala toolchain present"
  fi
  have sbt || brew install sbt || warn "sbt install failed"
fi

# --- Python ------------------------------------------------------------------
# uv for projects/venvs (fast, and the one you actually use day to day),
# pipx for global CLI tools. Both from brew; the system python3 stays untouched.
if want python; then
  say "Python"
  have uv   || brew install uv   || warn "uv install failed"
  have pipx || brew install pipx || warn "pipx install failed"
  have pipx && pipx ensurepath >/dev/null 2>&1 || true
  echo "    python3: $(python3 --version 2>&1)"
fi

# --- Rust --------------------------------------------------------------------
# rustup, NOT brew: brew's rust is a single pinned version with no toolchain
# management. rustup owns ~/.cargo and ~/.rustup and handles updates.
if want rust; then
  say "Rust"
  if have rustc; then
    echo "    already: $(rustc --version)"
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    # shellcheck disable=SC1091
    [ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
  fi
  # rust-analyzer powers the LSP in nvim; clippy/rustfmt back the editor's
  # lint + format on save.
  if have rustup; then
    rustup component add rust-analyzer clippy rustfmt rust-src 2>/dev/null || true
  fi
fi

# --- Node --------------------------------------------------------------------
# nvm, NOT brew: ~/.zshrc lazy-loads it and auto-switches on .nvmrc, which
# needs nvm proper. bun is separate and installs itself.
if want node; then
  say "Node"
  export NVM_DIR="$HOME/.nvm"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash
  else
    echo "    nvm already installed"
  fi
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  if ! nvm ls --no-colors 2>/dev/null | grep -q "v2[0-9]"; then
    nvm install --lts && nvm alias default 'lts/*'
  else
    echo "    node: $(node --version 2>/dev/null)"
  fi

  if have bun; then
    echo "    bun already installed"
  else
    curl -fsSL https://bun.sh/install | bash
  fi
fi

# --- Claude Code -------------------------------------------------------------
# Native installer -> ~/.local/share/claude, symlinked into ~/.local/bin.
# It self-updates, so there is nothing to pin or re-run here.
if want claude; then
  say "Claude Code"
  if have claude; then
    echo "    already: $(claude --version 2>/dev/null)"
  else
    curl -fsSL https://claude.ai/install.sh | bash || warn "claude install failed"
    warn "run 'claude' once to sign in"
  fi
fi

# --- summary -----------------------------------------------------------------
say "Versions"
for t in "java:java -version" "scala:scala-cli version --cli" "python3:python3 --version" \
         "uv:uv --version" "rustc:rustc --version" "node:node --version" \
         "bun:bun --version" "claude:claude --version"; do
  bin=${t%%:*}; cmd=${t#*:}
  if have "$bin"; then
    printf '    %-8s %s\n' "$bin" "$($cmd 2>&1 | head -1)"
  else
    printf '    %-8s %s\n' "$bin" "(not installed — open a new shell if just installed)"
  fi
done

cat <<'EOF'

Note: rust, node and bun add themselves to PATH via ~/.cargo/env, nvm and
~/.bun — all already handled by this repo's zshrc. Open a NEW shell before
checking anything that reports "not installed" above.
EOF
