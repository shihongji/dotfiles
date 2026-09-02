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

### If `git pull` complains about local changes

Installers that append to shell profiles (`gh auth setup-git`, bun, some
language installers) write into files that are symlinks into this repo, so
their edits show up as uncommitted changes here. Check what it is:

```bash
git diff zsh/zshrc git/gitconfig
```

- **Duplicate `source` lines** (voice-loop, bun) — already in `zsh/zshrc`;
  discard them: `git checkout -- zsh/zshrc`
- **A git credential helper** from `gh auth setup-git` — real, but it belongs
  in the untracked local file. Discard it here and re-add it there:

  ```bash
  git checkout -- git/gitconfig
  GIT_CONFIG_GLOBAL=~/.gitconfig.local gh auth setup-git
  ```

`~/.gitconfig.local` is gitignored and included last, so it wins and never
dirties the repo.

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

## Syncthing — personal machines only

Peer-to-peer file sync, no cloud in the middle. **Never install it on a work
laptop**: it would open a sync path between corporate and personal devices.

It is a formula (the cask was discontinued), and runs as a background service:

```bash
brew services start syncthing     # UI at http://127.0.0.1:8384
```

Pair devices by exchanging device IDs in that UI; there is no account. If you
ever run this repo's Brewfile on a work machine, delete the `syncthing` line
first.

## Raycast

Installed by the Brewfile. Its settings are **not** in this repo, on purpose:
they live in `~/Library/Preferences/com.raycast.macos.plist` (a binary plist of
mutable app state — analytics timestamps, migration flags, window positions),
and `~/.config/raycast/` is just compiled extension bundles Raycast rebuilds
itself. Neither is meaningful to version-control or diff.

Carry settings over with Raycast's own export, which is what it is designed for:

**Old Mac** — Raycast → Settings → Advanced → *Export Settings & Data*
(hotkeys, aliases, quicklinks, snippets, extension list and their prefs).
**New Mac** — install Raycast, then Settings → Advanced → *Import*.

Raycast Pro syncs this automatically across machines; the export is the free path.

Only carry over the extensions you actually want — a work machine's list tends
to accumulate company-specific ones.

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
