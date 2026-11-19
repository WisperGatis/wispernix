# Interactive-only setup for the native prompt (functions/fish_prompt.fish).
status is-interactive; or return

set -g fish_greeting
set -g fish_transient_prompt 1

# Repos owned by someone else (e.g. root-owned /etc/nixos) whose git status the
# prompt may read despite git's "dubious ownership" check. Add more paths here.
set -q wp_git_trusted; or set -g wp_git_trusted /etc/nixos

# Syntax highlighting + pager in the Noctalia palette (set once per shell;
# the prompt itself hot-reloads, `exec fish` refreshes these after a theme change).
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
abbr -a nrs 'sudo nixos-rebuild switch --flake .#nixos'
abbr -a nfu 'sudo nix flake update'
