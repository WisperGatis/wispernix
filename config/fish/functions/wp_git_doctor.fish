# Explains why the prompt shows ⚠ / no git status symbols in this directory.
function wp_git_doctor --description "Diagnose git status in the prompt"
    set -l trust (_wp_git_trust)
    echo "dir:      $PWD"
    echo "trusted:  $wp_git_trusted"
    test (count $trust) -gt 0; and echo "match:    yes ($trust[2])"; or echo "match:    no (dir not under any trusted path)"
    echo "git:      "(git --version)" as "(id -un)
    echo "--- git status (real output) ---"
    command git $trust --no-optional-locks status --porcelain=v2 --branch 2>&1 | head -12
    echo "exit:     $pipestatus[1]"
    echo "--- permissions ---"
    set -l top (command git $trust rev-parse --show-toplevel 2>/dev/null)
    test -z "$top"; and set top $PWD
    ls -ld $top $top/.git $top/.git/index 2>&1
end
