# brew bundle --file=Brewfile
#
# Derived from `brew leaves` on the old machine, minus work-only tooling
# (awscli, kubernetes-cli, maven, sbt, postgresql@15, golangci-lint, hurl,
# posting, gemini-cli — reinstall individually if you actually want them).

tap "koekeishiya/formulae"   # skhd, for voice-loop's global hotkeys

# --- shell -------------------------------------------------------------------
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "starship"              # prompt
brew "zoxide"                # smarter cd  (`z`, `zi`)
brew "fzf"                   # fuzzy finder — powers Ctrl-R / Ctrl-T and `bm`
brew "tmux"

# --- core CLI utils ----------------------------------------------------------
brew "ripgrep"               # rg   — aliased over grep
brew "fd"                    # find replacement; backs FZF_DEFAULT_COMMAND
brew "bat"                   # cat with syntax highlighting; fzf preview
brew "eza"                   # ls replacement (icons, git status)
brew "jq"                    # JSON — required by `bm`
brew "tree"
brew "duf"                   # disk usage
brew "tldr"                  # concise man pages
brew "unzip"
brew "make"
brew "cmake"

# --- git ---------------------------------------------------------------------
brew "git-lfs"
brew "gh"
brew "lazygit"
brew "gitui"

# --- editor / languages ------------------------------------------------------
brew "neovim"
brew "python@3.12"
brew "pipx"
brew "yarn"
brew "markdown-oxide"        # markdown LSP (used by the nvim config)

# --- voice-loop (local TTS/STT) ---------------------------------------------
brew "ffmpeg"
brew "whisper-cpp"           # CPU build; see voice-loop docs for a Metal build
brew "cava"                  # audio visualizer for the dashboard
brew "mpv"
brew "koekeishiya/formulae/skhd"   # global hotkeys (Alt+C stop, Alt+S skip)

# --- misc --------------------------------------------------------------------
brew "fastfetch"
brew "d2"                    # diagram DSL
brew "poppler"               # pdftotext etc; used by the kami skill
brew "tty-clock"
brew "wallpaper"

# --- casks -------------------------------------------------------------------
cask "ghostty"
cask "font-jetbrains-mono-nerd-font"   # the Ghostty font — required
cask "font-hack-nerd-font"
cask "font-meslo-lg-nerd-font"
cask "visual-studio-code"
cask "background-music"
cask "blackhole-2ch"         # loopback audio device (voice-loop / cava)
