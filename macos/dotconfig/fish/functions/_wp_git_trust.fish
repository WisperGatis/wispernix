# Prints `-c` `safe.directory=<path>` (two lines) when $PWD is inside a path
# listed in $wp_git_trusted; prints nothing otherwise.
function _wp_git_trust
    set -l here (path resolve $PWD)
    for t in $wp_git_trusted
        set t (path resolve $t)
        if test "$here" = "$t"; or string match -q -- "$t/*" $here
            printf '%s\n' -c safe.directory=$t
            return 0
        end
    end
    return 1
end
