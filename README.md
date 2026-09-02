# dotfiles

Personal macOS dev environment: zsh, Ghostty, starship, git, CLI utils, Claude
Code, and the local voice loop. Contains nothing employer-specific.

## Install on a new Mac

Clone over **HTTPS** — a fresh Mac has no SSH key yet, and this repo is public,
so this works before any auth is set up:

```bash
git clone https://github.com/shihongji/dotfiles.git ~/code/personal/dotfiles
cd ~/code/personal/dotfiles
./install.sh
```

`./install.sh --dry-run` to preview, `--link` for symlinks only (no brew).
Re-running is safe: existing real files are backed up to `<name>.bak-<ts>`
before being replaced by a symlink.

Once you've set up an SSH key (step 1 of the installer's closing notes), switch
the remote so you can push:

```bash
git remote set-url origin git@github.com:shihongji/dotfiles.git
```

> **This repo is public.** Nothing employer-specific, and no secrets, belong in
> it — machine-local files (`~/.zshrc.local`, `~/.gitconfig.local`) are
> gitignored precisely so that boundary is impossible to cross by accident.

## Layout

| Path | Links to | What |
|---|---|---|
| `zsh/zshrc` | `~/.zshrc` | shell core: PATH, plugins, aliases, fzf, lazy nvm |
| `zsh/zshenv` | `~/.zshenv` | cargo env (all shells) |
| `zsh/zprofile` | `~/.zprofile` | login-shell PATH |
| `ghostty/config` | `~/.config/ghostty/config` | JetBrainsMono NF 15, Catppuccin auto light/dark, 0.80 opacity + blur |
| `starship/starship.toml` | `~/.config/starship.toml` | gruvbox_dark powerline prompt |
| `git/gitconfig` | `~/.gitconfig` | personal identity, LFS, `pull.ff=only` |
| `git/ignore` | `~/.config/git/ignore` | global gitignore |
| `bin/nvim-tmux-split` | `~/bin/nvim-tmux-split` | `$EDITOR`: opens nvim in a tmux split |
| `cava/`, `mpv/` | `~/.config/…` | audio visualizer (voice-loop dashboard), mpv + YouTube |
| `claude/` | `~/.claude/…` | Claude Code settings, CLAUDE.md, skills, agents |
| `Brewfile` | — | packages, fonts, casks |
| `FONTS.md` | — | the terminal font: name, download links, variants |

## Font

**JetBrains Mono Nerd Font**, size 15, set in `ghostty/config` — the single
source of truth. nvim, tmux and starship set no font of their own; they inherit
it from the terminal. It must be the *Nerd Font* build, since starship, `eza
--icons` and the tmux status bar draw glyphs plain JetBrains Mono doesn't have.

Installed by the Brewfile (`font-jetbrains-mono-nerd-font`); manual download
links, variant differences (Mono / Propo / NL) and troubleshooting are in
[FONTS.md](FONTS.md).

## mpv + YouTube

`mpv "https://www.youtube.com/watch?v=..."` streams directly — `mpv/mpv.conf`
sets an `ytdl-format` that prefers H.264 (`avc1`), which Apple Silicon decodes
in hardware instead of burning CPU on VP9. Needs **`yt-dlp`**, pinned explicitly
in the Brewfile (it also arrives as an mpv dependency, but relying on that would
break silently if the dep ever went away).

## Machine-local overrides

Two files are gitignored and sourced/included last, so the same repo works on a
personal and a work machine:

- **`~/.zshrc.local`** — corp proxies, internal registries, cert bundles,
  `JAVA_HOME` pins, managed-tool PATH blocks. Seeded from
  `zsh/zshrc.local.example` on first install.
- **`~/.gitconfig.local`** — work identity and `url.insteadOf` host rewrites.
  Overrides the `[user]` block in `git/gitconfig`.

**Anything employer-specific goes in these two files, never in the repo.**

## Sibling repos

Kept separate so they stay independently versioned. `install.sh` clones them
once their remotes are set at the bottom of the script:

| Repo | Lands at | Status |
|---|---|---|
| `nvim-config` | `~/.config/nvim` | private — needs SSH auth |
| `tmux-config` | `~/code/personal/tmux-config`, symlinked to `~/.config/tmux` | public ✅ |
| `voice-loop` | `~/code/personal/voice-loop` | public ✅ |
| `bing-wallpaper` | `~/code/personal/bing-wallpaper` | public ✅ |

These are private, so cloning them needs an SSH key. A clone failure is
non-fatal — the rest of the install still completes; just re-run `./install.sh`
after `gh auth login` and it picks up whatever is missing.

## Language toolchains

`./install-toolchains.sh` — Java, Scala, Python, Rust, Node, and Claude Code.
Run it after `install.sh`. Safe to re-run; pass names to do a subset:

```bash
./install-toolchains.sh              # everything
./install-toolchains.sh rust node    # just those
```

Separate from `install.sh` because **none of these come from Homebrew** — each
ships its own installer and version manager:

| | Installed via | Why not brew |
|---|---|---|
| Java | `--cask temurin` | full JDK registered with `java_home`; the Brewfile's `openjdk` only runs JARs |
| Scala | `coursier` + `cs setup` | pulls scala, sbt, scalafmt, bloop, metals together |
| Python | `uv` + `pipx` | uv for venvs/projects, pipx for global CLIs; system python3 untouched |
| Rust | `rustup` | brew's rust is one pinned version with no toolchain management |
| Node | `nvm` + `bun` | zshrc lazy-loads nvm and auto-switches on `.nvmrc` |
| Claude Code | native installer | lives in `~/.local/share/claude`, self-updating |

Rust also gets `rust-analyzer`, `clippy`, `rustfmt` and `rust-src` for the nvim LSP.

## Bing wallpaper

A Scala util that fetches Bing's daily UHD homepage image and sets it as the
desktop across all screens. Own repo, own installer:

```bash
cd ~/code/personal/bing-wallpaper && ./install-agent.sh --now
```

That builds the JAR and registers a launchd agent for a 06:00 daily refresh.
Needs `wallpaper` + `openjdk` (both in the Brewfile); `scala-cli` only to build
from source.

## Voice loop (TTS / STT)

Local, offline: Kokoro-82M via MLX for speech, whisper.cpp with Metal for
dictation, plus a tmux dashboard. Lives in its own repo and has its own
`install.sh` (Python venv + ~1.6GB model download + skhd hotkeys). The Claude
Code `PreToolUse` / `Stop` hooks that drive it are already in
`claude/settings.json`.

## CLI tools this config assumes

`rg` `fd` `bat` `eza` `jq` `fzf` `zoxide` `starship` `tmux` `nvim` `gh`
`lazygit` `gitui` `duf` `tldr` `tree` `d2` `mpv` `yt-dlp`. Aliases are guarded —
a missing tool degrades rather than shadowing the real command with a broken
alias.

| Alias | Runs | Why |
|---|---|---|
| `ls` / `ll` / `la` / `lt` | `eza` | icons, git status, tree mode |
| `cat` | `bat` | syntax highlighting, line numbers |
| `grep` | `rg` | faster, respects `.gitignore` |
| `v` / `vim` | `$EDITOR` | nvim in a tmux split |
| `z` / `zi` | `zoxide` | jump to frecent dirs |
| Ctrl-R / Ctrl-T | `fzf` | history / file search (`fd` + `bat` preview) |

## Not migrated (work machine only)

Left behind deliberately: internal Nexus/proxy exports, corp cert sourcing,
Rancher Desktop PATH blocks, work git host rewrites, internal MCP servers and
plugin marketplaces, audit-logger hooks, and the `incident-analysis` skill.
