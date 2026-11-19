# Right side: exit status on failure (per-pipe if it was a pipeline), then time.
function fish_right_prompt
    set -l pipes $pipestatus
    set -l last_status $status
    contains -- --final-rendering $argv; and return
    _wp_palette
    set -l reset (set_color normal)
    set -l out

    set -l failed 0
    for p in $pipes
        test $p -ne 0; and set failed 1
    end
    if test $failed -eq 1; and test $last_status -ne 0
        set -a out (set_color -o $__wp_red)"✘ "(string join '|' -- $pipes)$reset
    end
    set -a out (set_color -o $__wp_subtext0)(date +%H:%M)$reset
    string join ' ' -- $out
end
