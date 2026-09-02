# brew bundle --file=Brewfile
#
# Derived from `brew leaves` on the old machine, minus work-only tooling
# (awscli, kubernetes-cli, maven, sbt, postgresql@15, golangci-lint, hurl,
# posting, gemini-cli — reinstall individually if you actually want them).

# One third-party tap. brew asks you to trust it the first time (it is the
# skhd/yabai author's). Optional — skhd only adds voice-loop's global hotkeys;
# decline it and everything else still installs.
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
# desktop on macOS 14+; openjdk runs the packaged JAR.
#
# scala-cli (needed only to BUILD the JAR from source) is deliberately NOT here:
# its formula is in an untrusted third-party tap that `brew bundle` refuses
# without an explicit `brew trust`, which made this line fail every time.
# install-toolchains.sh installs it via coursier instead — no tap required.
brew "wallpaper"
brew "openjdk"

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

# --- browsers ----------------------------------------------------------------
# Firefox is the daily driver: Chrome's Manifest V3 dropped the blocking
# webRequest API, so uBlock Origin only runs in reduced "Lite" form there.
# Firefox keeps the full version. Chrome stays for devtools, sites that only
# certify Chrome, and because the `bm` function reads its bookmarks JSON.
cask "firefox"
cask "google-chrome"

# --- apps --------------------------------------------------------------------
cask "raycast"               # launcher / clipboard history / window mgmt
cask "spotify"
cask "readest"               # EPUB reader, syncs across devices
cask "obsidian"              # notes; per-vault settings live in .obsidian/
cask "typora"                # single-document markdown editor (paid, ~$15)

# --- containers --------------------------------------------------------------
# OrbStack over Docker Desktop: same `docker` CLI and compose, but far lighter
# on CPU/battery and much faster to start. Free for personal use, whereas
# Docker Desktop now requires a paid subscription for larger companies —
# irrelevant on a personal Mac, but OrbStack is simply the better tool here.
# Swap for `cask "docker-desktop"` if you need its GUI/extensions.
cask "orbstack"

# boring-notch (notch → media/HUD widget) is NOT in homebrew-cask; it only
# exists in the author's tap, so brew will ask you to trust it. Declared last
# because a declined trust prompt should not hold up anything above.
tap "theboredteam/boring-notch"
cask "theboredteam/boring-notch/boring-notch"
