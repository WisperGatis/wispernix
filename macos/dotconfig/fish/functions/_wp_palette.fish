# Loads the Noctalia palette out of ~/.config/starship.toml into
# $__wp_<name> globals (hex without '#'). Noctalia rewrites that file on every
# theme change, so we re-parse it only when its mtime moves: the prompt follows
# the wallpaper theme without a restart, at the cost of one stat per prompt.
function _wp_palette --description "Load the Noctalia palette (cached by mtime)"
    set -l file $HOME/.config/starship.toml
    set -l stamp none
    test -r $file; and set stamp (path mtime $file)
    test "$stamp" = "$__wp_palette_stamp"; and return 0
    set -g __wp_palette_stamp $stamp

    # Fallback = the Rosé Pine Noctalia palette (same as starship-palette.toml).
    set -l defaults \
        blue 9ccfd8 red eb6f92 green 3e8fb0 yellow f6c177 \
        mauve c4a7e7 pink c4a7e7 peach f6c177 teal ea9a97 sky ea9a97 \
        lavender c4a7e7 base 232136 text e0def4 subtext0 6e6a86 surface1 393552
    for i in (seq 1 2 (count $defaults))
        set -g __wp_$defaults[$i] $defaults[(math $i + 1)]
    end

    test -r $file; or return 0
    set -l in_palette 0
    while read -l line
        if string match -rq '^\[palettes\.noctalia\]' -- $line
            set in_palette 1
        else if string match -rq '^\[' -- $line
            set in_palette 0
        else if test $in_palette -eq 1
            set -l m (string match -r '^(\w+)\s*=\s*"#?([0-9a-fA-F]{6})"' -- $line)
            and set -g __wp_$m[2] $m[3]
        end
    end <$file
end
