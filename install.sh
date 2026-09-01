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
  # A clone failure here must not abort the install (set -e): these repos are
  # private, so a machine without a key yet will fail this step and still want
  # the rest of the setup. Re-running after `gh auth login` picks them up.
  clone_or_report() {  # $1 = url ("" if unset), $2 = dest, $3 = label
    if [ -z "$1" ]; then warn "$3: no remote set yet — clone manually into $2"; return 0; fi
    if [ -d "$2/.git" ]; then echo "    ok   $2"; return 0; fi
    if ! run git clone "$1" "$2"; then
      warn "$3: clone failed (private repo — set up SSH auth, then re-run ./install.sh)"
    fi
    return 0
  }
  mkdir -p "$HOME/.config" "$HOME/code/personal"

  # tmux-config and voice-loop are public -> HTTPS, so they clone with no auth
  # on a fresh Mac. nvim-config is PRIVATE, so that one needs an SSH key: do
  # step 1 of the closing notes first, or just re-run ./install.sh afterwards
  # (repos already present are skipped, so re-running only fills the gaps).
  NVIM_REMOTE="git@github.com:shihongji/nvim-config.git"
  TMUX_REMOTE="https://github.com/shihongji/tmux-config.git"
  VOICELOOP_REMOTE="https://github.com/shihongji/voice-loop.git"

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

# --- 5. verify ---------------------------------------------------------------
if [ "$DRY_RUN" = 0 ]; then
  say "Verifying"
  missing=()
  for t in rg fd bat eza jq fzf zoxide starship tmux nvim git mpv yt-dlp; do
    command -v "$t" >/dev/null 2>&1 || missing+=("$t")
  done
  if [ ${#missing[@]} -gt 0 ]; then
    warn "not on PATH: ${missing[*]}"
    warn "(open a new shell first; if still missing, re-run: brew bundle --file=Brewfile)"
  else
    echo "    all CLI tools present"
  fi

  # The terminal font is a hard requirement for the prompt/icons, so check it
  # here rather than letting it show up later as unexplained tofu glyphs.
  if ls "$HOME/Library/Fonts" /Library/Fonts 2>/dev/null \
       | grep -qi "JetBrainsMonoNerdFont"; then
    echo "    JetBrainsMono Nerd Font installed"
  else
    warn "JetBrainsMono Nerd Font NOT found — the prompt will show tofu glyphs."
    warn "  brew install --cask font-jetbrains-mono-nerd-font   (see FONTS.md)"
  fi
fi

# --- 6. what's left to do by hand -------------------------------------------
cat <<'EOF'

Done. Remaining manual steps:

1) voice-loop (TTS/STT) — cloned already, but needs its own install:
     cd ~/code/personal/voice-loop && ./install.sh
   That builds the Python venv (mlx-audio), downloads Kokoro-82M (~1.6GB),
   and wires the skhd hotkeys. Then grant skhd Accessibility permission:
   System Settings -> Privacy & Security -> Accessibility.
   Its Claude Code hooks are already in claude/settings.json.

2) SSH key for GitHub — only needed to PUSH, or to clone nvim-config
   (the one private repo; the rest cloned over HTTPS already):
     ssh-keygen -t ed25519 -f ~/.ssh/id_personal_github -C "shihongji21@gmail.com"
     gh auth login --hostname github.com
     gh ssh-key add ~/.ssh/id_personal_github.pub
   Then re-run ./install.sh to pick up nvim-config.
   To push these repos, switch each remote to SSH:
     git -C <dir> remote set-url origin git@github.com:shihongji/<repo>.git

3) Open a new terminal, then check: rg, fd, bat, eza, fzf, starship, zoxide.
   Streaming check:  mpv "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

4) Ghostty: FULLY QUIT and reopen it (not just the window) so JetBrainsMono
   Nerd Font is picked up. Tofu/□ glyphs in the prompt mean the font didn't
   load — see FONTS.md.
EOF
