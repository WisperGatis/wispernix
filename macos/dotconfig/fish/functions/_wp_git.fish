# One `git status` call -> "<branch> <flags>" (flags in starship's style).
# Prints nothing outside a repository.
function _wp_git --description "Git branch and status summary for the prompt"
    set -l trust (_wp_git_trust)
    set -l out (command git $trust --no-optional-locks status --porcelain=v2 --branch 2>/dev/null)
    # git refuses repos we don't own ("dubious ownership") or can't fully read:
    # fall back to reading .git/HEAD by hand (no git process, no safe.directory bypass).
    or begin
        _wp_git_head
        return
    end
    set -l branch ""
    set -l oid ""
    set -l upstream ""
    set -l ahead 0
    set -l behind 0
    set -l staged 0
    set -l modified 0
    set -l deleted 0
    set -l untracked 0
    set -l conflicted 0

    for l in $out
        switch $l
            case '# branch.oid *'
                set oid (string sub -l 7 -- (string sub -s 14 -- $l))
            case '# branch.head *'
                set branch (string sub -s 15 -- $l)
            case '# branch.upstream *'
                set upstream (string sub -s 19 -- $l)
            case '# branch.ab *'
                set -l ab (string match -r '\+(\d+) -(\d+)' -- $l)
                set ahead $ab[2]
                set behind $ab[3]
            case '1 *' '2 *'
                set -l xy (string sub -s 3 -l 2 -- $l)
                test (string sub -l 1 -- $xy) != .; and set staged (math $staged + 1)
                switch (string sub -s 2 -l 1 -- $xy)
                    case M T; set modified (math $modified + 1)
                    case D; set deleted (math $deleted + 1)
                end
            case 'u *'
                set conflicted (math $conflicted + 1)
            case '? *'
                set untracked (math $untracked + 1)
        end
    end

    # Detached HEAD: show the short hash instead of "(detached)".
    test "$branch" = "(detached)"; and set branch $oid

    set -l flags
    test $conflicted -gt 0; and set -a flags "="
    test $staged -gt 0; and set -a flags "+"
    test $modified -gt 0; and set -a flags "!"
    test $deleted -gt 0; and set -a flags "✘"
    test $untracked -gt 0; and set -a flags "?"
    test $ahead -gt 0; and set -a flags "⇡$ahead"
    test $behind -gt 0; and set -a flags "⇣$behind"

    printf '%s\n%s\n%s\n' $branch (string join '' -- $flags) $upstream
end
