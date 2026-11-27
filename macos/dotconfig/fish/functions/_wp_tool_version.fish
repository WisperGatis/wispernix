# Prints a tool's version ("v1.2.3"). Cached per resolved binary path, so
# entering a project does not spawn python/node/rustc/go on every prompt;
# `nix develop` / venv switches change the binary path and refresh it.
function _wp_tool_version --argument-names tool
    set -l bin (command -s $tool); or return 1
    set -l binvar __wp_verbin_$tool
    set -l vervar __wp_ver_$tool
    if test "$$binvar" != "$bin"
        set -l raw
        switch $tool
            case python; set raw ($bin --version 2>&1)
            case node; set raw ($bin --version 2>&1)
            case rustc; set raw ($bin --version 2>&1)
            case go; set raw ($bin version 2>&1)
        end
        set -l v (string match -r '\d+(\.\d+)+' -- $raw)[1]
        set -g $binvar $bin
        set -g $vervar "v$v"
    end
    echo -n $$vervar
end
