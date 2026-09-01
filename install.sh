#!/usr/bin/env bash
# dotfiles installer. Idempotent — safe to re-run.
#
#   ./install.sh            # everything
#   ./install.sh --link     # symlinks only, no brew, no repo cloning
#   ./install.sh --dry-run  # show what would happen
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
DO_BREW=1
DO_REPOS=1

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --link)    DO_BREW=0; DO_REPOS=0 ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  ! \033[0m%s\n' "$*"; }
run()  { if [ "$DRY_RUN" = 1 ]; then echo "    [dry-run] $*"; else "$@"; fi; }

# link <source-in-repo> <target-path>
# Backs up an existing real file to <target>.bak-<timestamp> before replacing,
# so a first run on a machine that already has dotfiles never loses them.
link() {
  local src="$REPO/$1" dst="$2"
  if [ ! -e "$src" ]; then warn "missing in repo: $1"; return; fi
  run mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    local cur; cur="$(readlink "$dst")"
    if [ "$cur" = "$src" ]; then echo "    ok   $dst"; return; fi
    run rm "$dst"
  elif [ -e "$dst" ]; then
    local bak="$dst.bak-$(date +%Y%m%d-%H%M%S)"
    warn "backing up existing $dst -> $bak"
    run mv "$dst" "$bak"
  fi
  run ln -s "$src" "$dst"
  echo "    link $dst -> $src"
}

# --- 0. sanity ---------------------------------------------------------------
[ "$(uname -s)" = "Darwin" ] || { echo "macOS only"; exit 1; }

# --- 1. Homebrew + packages --------------------------------------------------
if [ "$DO_BREW" = 1 ]; then
  if ! command -v brew >/dev/null 2>&1; then
    say "Installing Homebrew"
    run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Apple Silicon puts brew outside the default PATH; make it usable now.
    [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  say "Installing packages from Brewfile (this takes a while)"
  run brew bundle --file="$REPO/Brewfile"
fi

# --- 2. symlinks -------------------------------------------------------------
say "Linking shell config"
link zsh/zshrc     "$HOME/.zshrc"
link zsh/zshenv    "$HOME/.zshenv"
link zsh/zprofile  "$HOME/.zprofile"

say "Linking tools"
link ghostty/config          "$HOME/.config/ghostty/config"
link starship/starship.toml  "$HOME/.config/starship.toml"
link git/gitconfig           "$HOME/.gitconfig"
link git/ignore              "$HOME/.config/git/ignore"
link bin/nvim-tmux-split     "$HOME/bin/nvim-tmux-split"
link cava/config             "$HOME/.config/cava/config"
link cava/config-mic         "$HOME/.config/cava/config-mic"
link mpv/mpv.conf            "$HOME/.config/mpv/mpv.conf"

say "Linking Claude Code config"
link claude/settings.json  "$HOME/.claude/settings.json"
link claude/CLAUDE.md      "$HOME/.claude/CLAUDE.md"
for d in "$REPO"/claude/skills/*/; do
  [ -d "$d" ] && link "claude/skills/$(basename "$d")" "$HOME/.claude/skills/$(basename "$d")"
done
for f in "$REPO"/claude/agents/*.md; do
  [ -e "$f" ] && link "claude/agents/$(basename "$f")" "$HOME/.claude/agents/$(basename "$f")"
done

# --- 3. machine-local escape hatches ----------------------------------------
if [ ! -e "$HOME/.zshrc.local" ]; then
  say "Seeding ~/.zshrc.local (machine-specific, never committed)"
  run cp "$REPO/zsh/zshrc.local.example" "$HOME/.zshrc.local"
fi
if [ ! -e "$HOME/.gitconfig.local" ]; then
  say "Creating empty ~/.gitconfig.local (work identity / host rewrites go here)"
  run touch "$HOME/.gitconfig.local"
fi

# --- 4. sibling repos -------------------------------------------------------
# These are separate repos rather than vendored, so they stay independently
# versioned. Set the remotes once and this clones them for you.
if [ "$DO_REPOS" = 1 ]; then
  say "Sibling repos"
  clone_or_report() {  # $1 = url ("" if unset), $2 = dest, $3 = label
    if [ -z "$1" ]; then warn "$3: no remote set yet — clone manually into $2"; return; fi
    if [ -d "$2/.git" ]; then echo "    ok   $2"; return; fi
    run git clone "$1" "$2"
  }
  mkdir -p "$HOME/.config" "$HOME/code/personal"

  NVIM_REMOTE="git@github.com:shihongji/nvim-config.git"
  TMUX_REMOTE=""        # TODO: set once the repo exists
  VOICELOOP_REMOTE=""   # TODO: set once the repo exists

  clone_or_report "$NVIM_REMOTE"      "$HOME/.config/nvim"                   "nvim"
  clone_or_report "$TMUX_REMOTE"      "$HOME/code/personal/tmux-config"      "tmux-config"
  clone_or_report "$VOICELOOP_REMOTE" "$HOME/code/personal/voice-loop"       "voice-loop"

  # tmux reads ~/.config/tmux; the config repo lives under code/personal.
  if [ -d "$HOME/code/personal/tmux-config" ]; then
    run mkdir -p "$HOME/.config/tmux"
    for t in tmux.conf scripts; do
      dst="$HOME/.config/tmux/$t"
      src="$HOME/code/personal/tmux-config/$t"
      if [ -e "$src" ] && [ ! -e "$dst" ]; then
        run ln -s "$src" "$dst"; echo "    link $dst -> $src"
      fi
    done
  fi
fi

# --- 5. what's left to do by hand -------------------------------------------
cat <<'EOF'

Done. Remaining manual steps:

1) SSH key for GitHub (personal):
     ssh-keygen -t ed25519 -f ~/.ssh/id_personal_github -C "shihongji21@gmail.com"
     gh auth login          # then: gh ssh-key add ~/.ssh/id_personal_github.pub
   No ssh config is installed — on a personal machine github.com uses the
   default key, so none is needed unless you add a second identity.

2) voice-loop (TTS/STT) — needs its own install after cloning:
     cd ~/code/personal/voice-loop && ./install.sh
   That builds the Python venv (mlx-audio), downloads Kokoro-82M (~1.6GB),
   and wires the skhd hotkeys. Then grant skhd Accessibility permission:
   System Settings -> Privacy & Security -> Accessibility.
   Its Claude Code hooks are already in claude/settings.json.

3) Open a new terminal, then check: rg, fd, bat, eza, fzf, starship, zoxide.

4) Ghostty: the config expects JetBrainsMono Nerd Font (installed via Brewfile).
   Restart Ghostty after the font lands or you'll get fallback glyphs.
EOF
