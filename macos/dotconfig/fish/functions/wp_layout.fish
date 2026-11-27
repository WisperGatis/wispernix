# wp_layout            show current layout + list
# wp_layout NAME       switch (saved universally, applies to every shell)
# wp_layout preview    render every layout in the current directory
function wp_layout --description "Switch / preview the prompt layout"
    set -l layouts lean twoline powerline pills minimal
    set -l cur lean
    set -q wp_layout; and set cur $wp_layout
    switch "$argv[1]"
        case ''
            for l in $layouts
                test $l = $cur; and echo "* $l"; or echo "  $l"
            end
        case preview
            for l in $layouts
                set_color -o brblack; echo "── $l"; set_color normal
                fish_prompt --layout $l; echo
                echo
            end
        case $layouts
            set -U wp_layout $argv[1]
        case '*'
            echo "wp_layout: unknown layout '$argv[1]' (try: $layouts preview)" >&2
            return 1
    end
end
