# Native fish port of config/starship/starship.toml, one line, left side:
#   <os> <dir> <git branch> <git status> <nix> <python> <node> <rust> <go> <duration> <jobs> <char>
# Improvements over the starship version: transient prompt, cached tool
# versions, venv name, one git call, upstream shown only when it differs,
# vi-mode aware character, palette hot-reloaded from Noctalia.
function fish_prompt
    set -l last_status $status
    _wp_palette
    set -l reset (set_color normal)

    # ── Transient (scrollback) rendering: just the character. ──
    if contains -- --final-rendering $argv
        set -l c $__wp_blue
        test $last_status -ne 0; and set c $__wp_red
        printf '%s❯%s ' (set_color -o $c) $reset
        return
    end

    set -l seg

    # os
    set -a seg (set_color -o $__wp_blue)$reset

    # directory (fish-style abbreviated parents, current dir kept whole)
    set -l pwd (prompt_pwd)
    set -l parts (string match -r '^(.*/)?([^/]*)$' -- $pwd)
    set -l dir (set_color $__wp_mauve)$parts[2](set_color -o $__wp_mauve)$parts[3]$reset
    if not test -w $PWD
        set dir $dir(set_color -o $__wp_red)" "$reset
    end
    set -a seg $dir

    # git
    set -l git (_wp_git)
    if test (count $git) -ge 1
        set -l branch $git[1]
        set -l flags $git[2]
        set -l upstream $git[3]
        set -l b (set_color -o $__wp_pink)" "$branch
        # show the upstream only when its name differs from the local branch
        if test -n "$upstream"; and test "$upstream" != "origin/$branch"
            set b $b":$upstream"
        end
        set -a seg $b$reset
        test -n "$flags"; and set -a seg (set_color -o $__wp_peach)$flags$reset
    end

    # nix shell
    if set -q IN_NIX_SHELL
        set -a seg (set_color -o $__wp_sky)" $IN_NIX_SHELL"$reset
    end

    # languages (only when their project marker is in the cwd)
    if set -q VIRTUAL_ENV; or test -e pyproject.toml -o -e requirements.txt -o -e setup.py -o -e Pipfile -o -e .python-version; or count *.py >/dev/null 2>&1
        set -l v (_wp_tool_version python)
        set -l env
        set -q VIRTUAL_ENV; and set env " ("(path basename $VIRTUAL_ENV)")"
        test -n "$v"; and set -a seg (set_color -o $__wp_yellow)" $v$env"$reset
    end
    if test -e package.json -o -e .node-version -o -e .nvmrc
        set -l v (_wp_tool_version node)
        test -n "$v"; and set -a seg (set_color -o $__wp_green)" $v"$reset
    end
    if test -e Cargo.toml
        set -l v (_wp_tool_version rustc)
        test -n "$v"; and set -a seg (set_color -o $__wp_peach)" $v"$reset
    end
    if test -e go.mod
        set -l v (_wp_tool_version go)
        test -n "$v"; and set -a seg (set_color -o $__wp_teal)" $v"$reset
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
        set -a seg (set_color -o $__wp_green)$d$reset
    end

    # background jobs
    set -l njobs (count (jobs -p))
    test $njobs -gt 0; and set -a seg (set_color -o $__wp_lavender)" $njobs"$reset

    # character: ❯ blue / red on failure, ❮ green in vi normal mode
    set -l char "❯"
    set -l c $__wp_blue
    if test "$fish_key_bindings" = fish_vi_key_bindings; and test "$fish_bind_mode" = default
        set char "❮"
        set c $__wp_green
    else if test $last_status -ne 0
        set c $__wp_red
    end

    printf '%s %s%s%s ' (string join ' ' -- $seg) (set_color -o $c) $char $reset
end
