# brew bundle --file=Brewfile
#
# Derived from `brew leaves` on the old machine, minus work-only tooling
# (awscli, kubernetes-cli, maven, sbt, postgresql@15, golangci-lint, hurl,
# posting, gemini-cli — reinstall individually if you actually want them).

# Third-party taps. brew asks you to trust each one the first time; both are
# well-known upstreams (skhd/yabai author, and the Scala CLI team). Neither is
# essential: skhd only adds voice-loop's global hotkeys, scala-cli only builds
# bing-wallpaper from source.
tap "koekeishiya/formulae"   # skhd, for voice-loop's global hotkeys
tap "virtuslab/scala-cli"    # scala-cli, to build bing-wallpaper's JAR

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
brew "koekeishiya/formulae/skhd"   # global hotkeys (Alt+C stop, Alt+S skip)

# --- media -------------------------------------------------------------------
brew "mpv"
# yt-dlp is what lets mpv play a YouTube/streaming URL directly:
#   mpv "https://youtube.com/watch?v=..."
# It currently arrives as an mpv dependency, so it is pinned explicitly here —
# if mpv ever drops the dep, streaming would break silently otherwise.
brew "yt-dlp"

# --- bing-wallpaper ----------------------------------------------------------
# Daily Bing UHD desktop image. `wallpaper` is the CLI that actually sets the
# desktop on macOS 14+; openjdk runs the packaged JAR. scala-cli is only needed
# to BUILD the JAR from source (or download it from the repo's Releases).
#
# scala-cli comes from a third-party tap, so brew will ask you to trust it
# (same prompt as skhd). It is OPTIONAL: you only need it to build the JAR
# yourself. Skip it and download bing-wallpaper.jar from the repo's Releases.
brew "wallpaper"
brew "openjdk"
brew "virtuslab/scala-cli/scala-cli"

# --- misc --------------------------------------------------------------------
brew "fastfetch"
brew "d2"                    # diagram DSL
brew "poppler"               # pdftotext etc; used by the kami skill
brew "tty-clock"

# --- casks -------------------------------------------------------------------
cask "ghostty"

# Fonts — see FONTS.md. JetBrainsMono NF is REQUIRED: it is the Ghostty font,
# and starship / eza / tmux depend on its Nerd Font glyphs. The other two are
# leftovers, safe to delete.
cask "font-jetbrains-mono-nerd-font"
cask "font-hack-nerd-font"
cask "font-meslo-lg-nerd-font"
cask "visual-studio-code"
cask "background-music"
cask "blackhole-2ch"         # loopback audio device (voice-loop / cava)
