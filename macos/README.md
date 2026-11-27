# macOS dotfiles: fish, tmux, Nerd Fonts

macOS-compatible versions of the fish and tmux setup from this NixOS repo.
Everything lives under `macos/` so it does not touch the NixOS config.

```
macos/
├── install.sh                  # one-shot setup: Homebrew packages, symlinks, fisher, TPM
├── dotconfig/                  # mirrors ~/.config
│   ├── fish/
│   │   ├── conf.d/wispernix.fish   # startup: abbreviations, colours, Homebrew PATH
│   │   ├── functions/*.fish        # native prompt (same as the NixOS repo)
│   │   └── fish_plugins            # fisher plugin list
│   └── tmux/tmux.conf              # tmux config (TPM plugins, Rosé Pine fallback colours)
└── fonts/
    └── install-nerd-fonts.sh       # install Nerd Fonts, no sudo needed
```

## Quick start

```bash
cd path/to/wispernix/macos
./install.sh --fonts        # packages + configs + JetBrainsMono Nerd Font
```

Then:

1. Restart your terminal so it picks up the font.
2. Open tmux and press `prefix + I` (prefix is `Ctrl+b`) to install the tmux plugins.
3. Optional: make fish your login shell with the `chsh` command the installer prints.

Requires [Homebrew](https://brew.sh). Existing files in `~/.config` are moved to
`~/.config-backup-<timestamp>/` before anything is linked.

## Nerd Fonts

```bash
./fonts/install-nerd-fonts.sh                 # JetBrainsMono (default)
./fonts/install-nerd-fonts.sh Hack FiraCode   # several at once
./fonts/install-nerd-fonts.sh --list          # what you can ask for
./fonts/install-nerd-fonts.sh --check         # what is already installed
./fonts/install-nerd-fonts.sh --method download   # skip Homebrew, fetch from GitHub
```

By default it uses `brew install --cask font-<name>-nerd-font`. Without Homebrew it
downloads the font zip from the official [ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts)
releases and copies the `.ttf`/`.otf` files into `~/Library/Fonts`.

Use the family name in your terminal settings, e.g. **`JetBrainsMono Nerd Font`**
(the name the NixOS configs use in `home/terminals.nix`, `wezterm.lua` and `rio/config.toml`).

## fish

- `dotconfig/fish/functions/` are copies of `config/fish/functions/`: the same prompt,
  `wp_layout` switcher and `wp_git_doctor`.
- `conf.d/wispernix.fish` is the macOS version. It drops the NixOS-only bits
  (`/etc/nixos` trust, `nrs`/`nfu` abbreviations) and adds Homebrew to `PATH`.
  It also ships a `seq` fallback, since the prompt uses `seq`.
- Plugins come from fisher (`fish_plugins`): `fzf.fish`, `autopair`, `sponge`, `done`.
- Add your own shared repos to `wp_git_trusted` in `conf.d/wispernix.fish` if git
  complains about "dubious ownership".

Because the `functions/` files are copies, changes made in `config/fish/functions/`
on NixOS do not reach this folder automatically. Copy them over if you want them on the Mac.

## tmux

- Mouse on, and drag-select copies to the macOS clipboard via `pbcopy`.
- Vi copy mode: `prefix + [`, then `v` to select and `y` to copy.
- Plugins: `tmux-resurrect` (save/restore sessions) and `tmux-continuum` (auto restore).
  Both are managed by TPM.
- The status bar uses the same rounded capsules as the NixOS setup. Colours fall back to
  Rosé Pine. If you run Noctalia, its `~/.config/tmux/themes/noctalia.conf` overrides them.

## Notes

- Icons in the prompt and tmux status bar need a Nerd Font set as your terminal font.
  Without one, you will see boxes or question marks.
- The installer symlinks configs, so editing a file in this repo changes your live setup.
- Tested: fish 3.7 syntax and prompt rendering, tmux 3.4 config load. The macOS
  scripts have not been run on a real Mac yet. Please report anything odd.
