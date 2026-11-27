#!/usr/bin/env bash
# install-nerd-fonts.sh : install Nerd Fonts on macOS (no sudo needed).
#
#   ./install-nerd-fonts.sh                     # JetBrainsMono (default, what the configs use)
#   ./install-nerd-fonts.sh Hack FiraCode       # several fonts
#   ./install-nerd-fonts.sh --list              # show the names you can pass
#   ./install-nerd-fonts.sh --check             # show which Nerd Fonts are installed
#   ./install-nerd-fonts.sh --method download   # skip Homebrew, fetch from GitHub
#
# Methods:
#   brew      (default when Homebrew is present) brew install --cask font-<name>-nerd-font
#   download  fetch <Name>.zip from ryanoasis/nerd-fonts releases into ~/Library/Fonts
set -euo pipefail

# Name           Homebrew cask                          Description
FONT_LIST="
JetBrainsMono font-jetbrains-mono-nerd-font   JetBrains Mono (default)
FiraCode      font-fira-code-nerd-font        Fira Code
Hack          font-hack-nerd-font             Hack
Meslo         font-meslo-lg-nerd-font         Meslo LG
CascadiaCode  font-caskaydia-cove-nerd-font   Cascadia Code
Iosevka       font-iosevka-nerd-font          Iosevka
UbuntuMono    font-ubuntu-mono-nerd-font      Ubuntu Mono
SymbolsOnly   font-symbols-only-nerd-font     Icons only (fallback glyphs)
"

FONT_DIR="$HOME/Library/Fonts"
RELEASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"

say()  { printf '%s\n' "$*"; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

list_fonts() {
    say "Available Nerd Fonts (pass the first column to install):"
    printf '%s\n' "$FONT_LIST" | awk 'NF { d = $0; sub(/^[^ ]+ +[^ ]+ +/, "", d); printf "  %-14s %s\n", $1, d }'
}

check_fonts() {
    say "Nerd Fonts found in your font folders:"
    local found=0 file
    for dir in "$FONT_DIR" /Library/Fonts; do
        [ -d "$dir" ] || continue
        for file in "$dir"/*[Nn]erd*; do
            [ -e "$file" ] || continue
            say "  $(basename "$file")"
            found=1
        done
    done
    [ "$found" -eq 1 ] || say "  (none yet)"
}

cask_for() {   # $1 = Name -> cask
    printf '%s\n' "$FONT_LIST" | awk -v n="$1" '$1 == n { print $2; exit }'
}

install_brew() {
    local name=$1 cask
    cask=$(cask_for "$name")
    [ -n "$cask" ] || die "unknown font '$name' (try --list)"
    say "→ brew install --cask $cask"
    brew install --cask "$cask" || brew reinstall --cask "$cask"
}

install_download() {
    local name=$1 tmp
    [ -n "$(cask_for "$name")" ] || die "unknown font '$name' (try --list)"
    command -v curl >/dev/null || die "curl is required"
    command -v unzip >/dev/null || die "unzip is required"
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' RETURN
    say "→ downloading $name.zip"
    curl -fL --progress-bar -o "$tmp/$name.zip" "$RELEASE_URL/$name.zip"
    mkdir -p "$tmp/unzipped" "$FONT_DIR"
    unzip -q -o "$tmp/$name.zip" -d "$tmp/unzipped"
    # Copy only font files; skip the README/LICENSE noise from the archive.
    find "$tmp/unzipped" -type f \( -iname '*.ttf' -o -iname '*.otf' \) -exec cp -f {} "$FONT_DIR/" \;
    say "→ copied into $FONT_DIR"
}

main() {
    local method="" fonts=()
    while [ $# -gt 0 ]; do
        case "$1" in
            --list)   list_fonts; exit 0 ;;
            --check)  check_fonts; exit 0 ;;
            --method) method=${2:-}; shift ;;
            -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
            -*) die "unknown option $1" ;;
            *)  fonts+=("$1") ;;
        esac
        shift
    done

    [ "$(uname -s)" = Darwin ] || die "this script is for macOS (use your distro's package manager on Linux)"
    [ ${#fonts[@]} -gt 0 ] || fonts=(JetBrainsMono)

    if [ -z "$method" ]; then
        command -v brew >/dev/null && method=brew || method=download
    fi

    for f in "${fonts[@]}"; do
        case "$method" in
            brew)     command -v brew >/dev/null || die "Homebrew not found (https://brew.sh) or use --method download"
                      install_brew "$f" ;;
            download) install_download "$f" ;;
            *)        die "unknown method '$method' (brew|download)" ;;
        esac
    done

    say ""
    say "✔ Done. Use the family name in your terminal, e.g. \"JetBrainsMono Nerd Font\"."
    say "  Restart your terminal (or Cmd+Q) so it sees the new fonts."
}

main "$@"
