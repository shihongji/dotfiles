# Fonts

## The one font that matters

**JetBrains Mono Nerd Font** — used everywhere: Ghostty, and therefore tmux,
nvim, starship, eza icons, and every other TUI. Nerd Fonts version **3.4.0** on
the old machine (3.5.1 is current; either is fine).

The exact string in `ghostty/config`:

```
font-family = JetBrainsMono Nerd Font
font-size = 15
```

> Note the family name has **no space** in "JetBrainsMono" but a space before
> "Nerd Font". Ghostty silently falls back to a default if the name is wrong,
> which shows up as missing/□ glyphs in the starship prompt and eza icons.

### Why a Nerd Font is required, not optional

The starship prompt, `eza --icons`, and the tmux status bar all draw glyphs from
the Nerd Fonts private-use range (powerline separators, git/language icons). A
plain JetBrains Mono has none of them and renders tofu boxes.

## Install

Handled by the `Brewfile` — no manual step:

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

Then **fully restart Ghostty** (quit, not just close the window) or the new font
won't be picked up.

### Manual download (non-Homebrew machines, Linux, another user)

- Release page: <https://github.com/ryanoasis/nerd-fonts/releases/latest>
- Direct zip: <https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip>
- Upstream (non-patched) JetBrains Mono: <https://www.jetbrains.com/lp/mono/>

macOS: unzip and copy the `.ttf` files into `~/Library/Fonts/`.
Linux: copy into `~/.local/share/fonts/` then `fc-cache -fv`.

```bash
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip -d ~/Library/Fonts/    # macOS
```

## Which variant to pick

The zip contains four naming families. Ghostty wants the first one:

| Family in the zip | Use |
|---|---|
| `JetBrainsMonoNerdFont-*` | **This one.** Icons sized to fit a single cell. |
| `JetBrainsMonoNerdFontMono-*` | Icons force-shrunk to strict monospace; icons look small. |
| `JetBrainsMonoNerdFontPropo-*` | Proportional — do not use in a terminal. |
| `JetBrainsMonoNLNerdFont-*` | "NL" = No Ligatures. Use if you dislike `!=` / `=>` ligatures. |

## Also installed (not required)

Both are leftovers, installed via the Brewfile only so nothing referencing them
breaks. Drop the two cask lines if you want a leaner install.

- **Hack Nerd Font** — `font-hack-nerd-font`
- **MesloLG Nerd Font** — `font-meslo-lg-nerd-font`

## Where fonts are *not* configured

`nvim` sets no font at all — it's a terminal app and inherits Ghostty's. Same
for tmux and starship. **Ghostty's config is the single source of truth**; change
the font there and everything follows.

The `kami` skill is the one exception: it embeds its own webfonts
(`claude/skills/kami/assets/fonts/`) for PDF output, unrelated to the terminal.
