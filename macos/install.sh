#!/usr/bin/env bash
# install.sh : set up fish + tmux from this folder on a Mac.
#
#   ./install.sh            link configs, install packages, bootstrap fisher
#   ./install.sh --no-brew  only link configs (Homebrew packages already present)
#   ./install.sh --fonts    also install JetBrainsMono Nerd Font
#
# Configs are SYMLINKED into ~/.config, so edits here apply right away.
# Existing files are moved to ~/.config-backup-<timestamp>/ first.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/dotconfig"
DST="$HOME/.config"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
WANT_BREW=1
WANT_FONTS=0

say() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

for arg in "$@"; do
    case "$arg" in
        --no-brew) WANT_BREW=0 ;;
        --fonts)   WANT_FONTS=1 ;;
        -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
        *) die "unknown option $arg" ;;
    esac
done

[ "$(uname -s)" = Darwin ] || die "this installer is for macOS"

# link SRC_FILE DST_FILE : back up what is there, then symlink
link() {
    local src=$1 dst=$2
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
            return 0   # already linked
        fi
        mkdir -p "$BACKUP/$(dirname "${dst#"$HOME"/}")"
        mv "$dst" "$BACKUP/${dst#"$HOME"/}"
        say "  backed up $dst"
    fi
    ln -s "$src" "$dst"
    say "  linked   ${dst#"$HOME"/}"
}

# ── 1. Homebrew packages ──────────────────────────────────
if [ "$WANT_BREW" -eq 1 ]; then
    if ! command -v brew >/dev/null; then
        die "Homebrew is missing. Install it from https://brew.sh then re-run this script."
    fi
    say "→ installing packages with Homebrew"
    brew install fish tmux git fzf fd bat eza zoxide
fi

# ── 2. Config symlinks ────────────────────────────────────
say "→ linking configs"
link "$SRC/tmux/tmux.conf" "$DST/tmux/tmux.conf"

for f in "$SRC"/fish/functions/*.fish; do
    link "$f" "$DST/fish/functions/$(basename "$f")"
done
for f in "$SRC"/fish/conf.d/*.fish; do
    link "$f" "$DST/fish/conf.d/$(basename "$f")"
done
# fish_plugins is copied, not linked: fisher rewrites it when you add plugins.
mkdir -p "$DST/fish"
if [ ! -e "$DST/fish/fish_plugins" ]; then
    cp "$SRC/fish/fish_plugins" "$DST/fish/fish_plugins"
    say "  copied   fish/fish_plugins"
fi

# ── 3. fisher + plugins (fish) ────────────────────────────
if command -v fish >/dev/null; then
    FISHER="$DST/fish/functions/fisher.fish"
    if [ ! -e "$FISHER" ]; then
        say "→ bootstrapping fisher"
        # Download to a .part file first so a failed download never leaves a broken fisher.fish.
        if curl -fsSL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish \
                -o "$FISHER.part"; then
            mv "$FISHER.part" "$FISHER"
        else
            rm -f "$FISHER.part"
            say "  could not download fisher (check your connection); plugins skipped"
        fi
    fi
    if [ -e "$FISHER" ]; then
        say "→ installing fish plugins"
        fish -c 'fisher update' || say "  (fisher reported a problem; run 'fisher update' in fish later)"
    fi
fi

# ── 4. TPM for tmux plugins ───────────────────────────────
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    say "→ installing TPM (tmux plugin manager)"
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
say "  open tmux and press  prefix + I  to install tmux plugins"

# ── 5. Optional: Nerd Font ────────────────────────────────
if [ "$WANT_FONTS" -eq 1 ]; then
    "$HERE/fonts/install-nerd-fonts.sh" JetBrainsMono
fi

# ── 6. Make fish the login shell ──────────────────────────
FISH_PATH="$(command -v fish || true)"
if [ -n "$FISH_PATH" ] && [ "${SHELL:-}" != "$FISH_PATH" ]; then
    if ! grep -qx "$FISH_PATH" /etc/shells; then
        say "→ adding $FISH_PATH to /etc/shells (needs your password)"
        echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi
    say "→ run  chsh -s $FISH_PATH  to make fish your default shell"
fi

say ""
say "✔ All set, Wispie-chan! ✨ Next: ./fonts/install-nerd-fonts.sh (if you skipped --fonts)"
