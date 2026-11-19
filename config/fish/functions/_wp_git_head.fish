# Branch-only fallback for repos `git status` refuses to read (not owned by us,
# unreadable index...). Walks up to find .git, parses HEAD. Prints the same
# 3-line shape as _wp_git, with a ⚠ flag (status unknown) and no upstream.
function _wp_git_head
    set -l d $PWD
    set -l gd
    while true
        if test -d $d/.git
            set gd $d/.git
            break
        else if test -f $d/.git   # worktree / submodule: "gitdir: <path>"
            read -l line <$d/.git
            set -l l (string replace -r '^gitdir:\s*' '' -- $line)
            string match -q '/*' -- $l; or set l $d/$l
            set gd $l
            break
        end
        test "$d" = /; and return 1
        set d (path dirname $d)
    end
    test -r $gd/HEAD; or return 1
    read -l head <$gd/HEAD
    set -l branch (string replace -r '^ref: refs/heads/' '' -- $head)
    # detached: raw hash
    test "$branch" = "$head"; and set branch (string sub -l 7 -- $head)
    # ⚠ = status unavailable (git refused or failed): run `wp_git_doctor`
    printf '%s\n%s\n%s\n' $branch ⚠ ''
end
