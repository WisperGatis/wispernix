# Native fish port of config/starship/starship.toml, with switchable layouts:
#   lean (default) · twoline · powerline · pills · minimal      -> `wp_layout`
# Segments are gathered once (name / colour hex / text), then a renderer
# lays them out. Also: transient prompt, cached tool versions, single git call,
# venv name, vi-mode aware character, palette hot-reloaded from Noctalia.
function fish_prompt
    set -l last_status $status
    argparse final-rendering 'layout=' -- $argv 2>/dev/null
    _wp_palette
    set -l reset (set_color normal)

    set -l layout $_flag_layout
    test -z "$layout"; and set layout $wp_layout
    contains -- $layout lean twoline powerline pills minimal; or set layout lean

    # character: ❯ blue / red on failure, ❮ green in vi normal mode
    set -l char "❯"
    set -l cc $__wp_blue
    if test "$fish_key_bindings" = fish_vi_key_bindings; and test "$fish_bind_mode" = default
        set char "❮"
        set cc $__wp_green
    else if test $last_status -ne 0
        set cc $__wp_red
    end

    # Transient (scrollback) rendering. `wp_transient` picks the style:
    #   time (default)  14:32 ❯      dir  wispernix ❯      char  ❯
    if set -q _flag_final_rendering
        set -l t $wp_transient
        test -z "$t"; and set t time
        set -l pre
        switch $t
            case time
                set pre (set_color $__wp_subtext0)(date +%H:%M)$reset" "
            case dir
                set pre (set_color $__wp_mauve)(path basename $PWD)$reset" "
        end
        printf '%s%s❯%s ' "$pre" (set_color -o $cc) $reset
        return
    end

    # ── gather segments: parallel lists names / cols (hex) / texts ──
    set -l names
    set -l cols
    set -l texts

    set -a names os;  set -a cols $__wp_blue; set -a texts 

    set -l pwd (prompt_pwd)
    set -l parts (string match -r '^(.*/)?([^/]*)$' -- $pwd)
    set -l dircol $__wp_mauve
    # Home gets its own look: a house icon, the username and a warm colour.
    if test "$PWD" = "$HOME"
        set pwd \uf015" "(id -un)" ~"
        set parts $pwd "" $pwd
        set dircol $__wp_yellow
    end
    set -a names dir; set -a cols $dircol; set -a texts $pwd
    if not test -w $PWD
        set -a names ro; set -a cols $__wp_red; set -a texts 
    end

    set -l git (_wp_git)
    set -l branch
    if test (count $git) -ge 1
        set branch $git[1]
        set -l upstream $git[3]
        set -l b " $branch"
        # show the upstream only when its name differs from the local branch
        if test -n "$upstream"; and test "$upstream" != "origin/$branch"
            set b $b":$upstream"
        end
        set -a names git; set -a cols $__wp_pink; set -a texts $b
        if test -n "$git[2]"
            set -a names flags; set -a cols $__wp_peach; set -a texts $git[2]
        end
    end

    if set -q IN_NIX_SHELL
        set -a names nix; set -a cols $__wp_sky; set -a texts " $IN_NIX_SHELL"
    end

    # languages (only when their project marker is in the cwd)
    if set -q VIRTUAL_ENV; or test -e pyproject.toml -o -e requirements.txt -o -e setup.py -o -e Pipfile -o -e .python-version; or count *.py >/dev/null 2>&1
        set -l v (_wp_tool_version python)
        set -l env
        set -q VIRTUAL_ENV; and set env " ("(path basename $VIRTUAL_ENV)")"
        test -n "$v"; and begin; set -a names python; set -a cols $__wp_yellow; set -a texts " $v$env"; end
    end
    if test -e package.json -o -e .node-version -o -e .nvmrc
        set -l v (_wp_tool_version node)
        test -n "$v"; and begin; set -a names node; set -a cols $__wp_green; set -a texts " $v"; end
    end
    if test -e Cargo.toml
        set -l v (_wp_tool_version rustc)
        test -n "$v"; and begin; set -a names rust; set -a cols $__wp_peach; set -a texts " $v"; end
    end
    if test -e go.mod
        set -l v (_wp_tool_version go)
        test -n "$v"; and begin; set -a names go; set -a cols $__wp_teal; set -a texts " $v"; end
    end

    # command duration (>= 500 ms)
    if test -n "$CMD_DURATION"; and test $CMD_DURATION -ge 500
        set -l ms $CMD_DURATION
        set -l d
        if test $ms -lt 60000
            set d (math --scale 3 $ms / 1000)s
        else
            set -l s (math --scale 0 "floor($ms / 1000)")
            set -l h (math --scale 0 "floor($s / 3600)")
            set -l m (math --scale 0 "floor(($s % 3600) / 60)")
            set s (math --scale 0 "$s % 60")
            test $h -gt 0; and set d {$h}h" "
            set d $d{$m}m" "{$s}s
        end
        set -a names duration; set -a cols $__wp_green; set -a texts $d
    end

    set -l njobs (count (jobs -p))
    test $njobs -gt 0; and begin; set -a names jobs; set -a cols $__wp_lavender; set -a texts " $njobs"; end

    set -l n (count $names)
    set -l ch (set_color -o $cc)$char$reset

    # ── renderers ──
    switch $layout
        case minimal
            # dir, branch, a dot when dirty, character
            set -l out (set_color -o $dircol)(path basename $pwd)$reset
            test -n "$branch"; and set out $out (set_color $__wp_pink)$branch$reset
            contains flags $names; and set out $out(set_color -o $__wp_peach)" ●"$reset
            printf '%s %s ' (string join ' ' -- $out) $ch

        case powerline
            set -l base $__wp_base
            set -l buf
            for i in (seq $n)
                set -l bg $cols[$i]
                set -l body " $texts[$i] "
                test $names[$i] = os; and set body " $texts[$i] "
                set -a buf (set_color -b $bg $base -o)$body
                if test $i -lt $n
                    set -l nbg $cols[(math $i + 1)]
                    if test "$bg" = "$nbg"
                        set -a buf (set_color -b $bg $base)
                    else
                        set -a buf (set_color $bg -b $nbg)
                    end
                else
                    set -a buf (set_color $bg -b normal)$reset
                end
            end
            printf '%s %s ' (string join '' -- $buf) $ch

        case pills
            set -l base $__wp_base
            set -l buf
            for i in (seq $n)
                set -l bg $cols[$i]
                set -a buf (set_color $bg)(set_color -b $bg $base -o)$texts[$i](set_color $bg -b normal)$reset
            end
            printf '%s %s ' (string join ' ' -- $buf) $ch

        case '*'   # lean / twoline share the segment rendering
            set -l buf
            for i in (seq $n)
                if test $names[$i] = dir
                    set -a buf (set_color $dircol)$parts[2](set_color -o $dircol)$parts[3]$reset
                else
                    set -a buf (set_color -o $cols[$i])$texts[$i]$reset
                end
            end
            if test $layout = twoline
                set -l g (set_color $__wp_subtext0)
                printf '%s╭─%s %s\n%s╰─%s%s ' $g $reset (string join ' ' -- $buf) $g $reset $ch
            else
                printf '%s %s ' (string join ' ' -- $buf) $ch
            end
    end
end
