# dotfiles

Personal macOS dev environment: zsh, Ghostty, starship, git, CLI utils, Claude
Code, and the local voice loop. Contains nothing employer-specific.

## Install on a new Mac

```bash
git clone git@github.com:shihongji/dotfiles.git ~/code/personal/dotfiles
cd ~/code/personal/dotfiles
./install.sh
```

`./install.sh --dry-run` to preview, `--link` for symlinks only (no brew).
Re-running is safe: existing real files are backed up to `<name>.bak-<ts>`
before being replaced by a symlink.

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
| `cava/`, `mpv/` | `~/.config/…` | audio visualizer (voice-loop dashboard), mpv |
| `claude/` | `~/.claude/…` | Claude Code settings, CLAUDE.md, skills, agents |
| `Brewfile` | — | packages, fonts, casks |

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
| `nvim-config` | `~/.config/nvim` | remote set ✅ |
| `tmux-config` | `~/code/personal/tmux-config`, symlinked to `~/.config/tmux` | **remote TODO** |
| `voice-loop` | `~/code/personal/voice-loop` | **remote TODO** |

## Voice loop (TTS / STT)

Local, offline: Kokoro-82M via MLX for speech, whisper.cpp with Metal for
dictation, plus a tmux dashboard. Lives in its own repo and has its own
`install.sh` (Python venv + ~1.6GB model download + skhd hotkeys). The Claude
Code `PreToolUse` / `Stop` hooks that drive it are already in
`claude/settings.json`.

## CLI tools this config assumes

`rg` `fd` `bat` `eza` `jq` `fzf` `zoxide` `starship` `tmux` `nvim` `gh`
`lazygit` `gitui` `duf` `tldr` `tree` `d2`. Aliases are guarded — a missing
tool degrades rather than shadowing the real command with a broken alias.

## Not migrated (work machine only)

Left behind deliberately: internal Nexus/proxy exports, corp cert sourcing,
Rancher Desktop PATH blocks, work git host rewrites, internal MCP servers and
plugin marketplaces, audit-logger hooks, and the `incident-analysis` skill.
