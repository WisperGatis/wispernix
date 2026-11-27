# macOS port of config/fish/conf.d/wispernix.fish (NixOS).
# Interactive-only setup for the native prompt (functions/fish_prompt.fish).
status is-interactive; or return

set -g fish_greeting
set -g fish_transient_prompt 1

# Homebrew on Apple Silicon lives in /opt/homebrew (Intel Macs use /usr/local,
# which is already on PATH). Only add it when it exists.
test -d /opt/homebrew/bin; and fish_add_path -gm /opt/homebrew/bin /opt/homebrew/sbin

# macOS does not ship GNU `seq`; the prompt uses it. Provide a tiny fallback
# only when the real one is missing (e.g. Homebrew's coreutils is not installed).
if not type -q seq
    function seq --description "Minimal seq fallback: seq [first [step]] last"
        set -l first 1
        set -l step 1
        set -l last
        switch (count $argv)
            case 1; set last $argv[1]
            case 2; set first $argv[1]; set last $argv[2]
            case 3; set first $argv[1]; set step $argv[2]; set last $argv[3]
            case '*'; return 1
        end
        set -l i $first
        while test $i -le $last
            echo $i
            set i (math $i + $step)
        end
    end
end

# Repos owned by another user (or otherwise refused by git's "dubious
# ownership" check) whose git status the prompt may read. Add your own paths
# here, e.g.  set -g wp_git_trusted ~/Projects/shared-repo
set -q wp_git_trusted; or set -g wp_git_trusted

# Syntax highlighting + pager in the Noctalia palette (falls back to Rosé Pine
# when ~/.config/starship.toml has no Noctalia palette, which is the usual case
# on a Mac without Noctalia). `exec fish` refreshes these after a theme change.
_wp_palette
set -g fish_color_command $__wp_blue
set -g fish_color_param $__wp_text
set -g fish_color_keyword $__wp_mauve
set -g fish_color_quote $__wp_yellow
set -g fish_color_redirection $__wp_sky
set -g fish_color_end $__wp_peach
set -g fish_color_error $__wp_red
set -g fish_color_comment $__wp_subtext0
set -g fish_color_operator $__wp_pink
set -g fish_color_escape $__wp_sky
set -g fish_color_autosuggestion $__wp_subtext0
set -g fish_color_valid_path --underline
set -g fish_color_selection --background=$__wp_surface1
set -g fish_color_search_match --background=$__wp_surface1
set -g fish_pager_color_prefix $__wp_pink --bold
set -g fish_pager_color_completion $__wp_text
set -g fish_pager_color_description $__wp_subtext0
set -g fish_pager_color_progress $__wp_subtext0
set -g fish_pager_color_selected_background --background=$__wp_surface1

# Abbreviations (expand in place, so history stays honest).
abbr -a g git
abbr -a gs 'git status -sb'
abbr -a ga 'git add'
abbr -a gc 'git commit'
abbr -a gp 'git push'
abbr -a gl 'git log --oneline --graph --decorate -20'
abbr -a gd 'git diff'
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a brewup 'brew update; and brew upgrade; and brew cleanup'
abbr -a tm 'tmux new -A -s main'
