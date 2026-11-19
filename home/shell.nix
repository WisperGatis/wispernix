{ config, pkgs, lib, inputs, ... }:
{
  programs.fish = {
    enable = true;

    # Prompt = native functions in config/fish (a port of the starship layout,
    # same Noctalia palette). Tide is gone.
    plugins = [
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }   # Ctrl+R history, Ctrl+Alt+F files, Ctrl+Alt+L git log
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }   # closes ( [ { " '
      { name = "sponge"; src = pkgs.fishPlugins.sponge.src; }       # drops failed commands from history
      { name = "done"; src = pkgs.fishPlugins.done.src; }           # desktop notification when a long command ends
    ];
  };

  xdg.configFile."fish/functions" = { source = ../config/fish/functions; recursive = true; };
  xdg.configFile."fish/conf.d/wispernix.fish".source = ../config/fish/conf.d/wispernix.fish;

  programs.zoxide = { enable = true; enableFishIntegration = true; enableZshIntegration = true; };   # `z dir`, `zi`
  programs.eza = { enable = true; enableFishIntegration = true; icons = "auto"; git = true; };         # ls/ll/la/lt
  programs.bat.enable = true;                                                                          # fzf.fish previews

  # fish has its own native prompt; zsh uses Starship with the Noctalia palette.
  # zsh is a quick-switch shell only; fish remains the login default.
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    # Suggests the rest of a command from past history as you type.
    autosuggestion.enable = true;
  };

  # fzf history search: Ctrl+R opens fuzzy-searchable past commands in zsh.
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = false;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = false;
    enableZshIntegration = true;
  };

  # Noctalia rewrites starship.toml on theme change, so it must stay a
  # writable file rather than a read-only Nix store symlink. Seed it from
  # the repo when it is missing, still a store symlink, or has lost its
  # layout (Noctalia writes a palette-only file when no config exists).
  home.activation.starshipConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    starship_config="$HOME/.config/starship.toml"
    if [ ! -e "$starship_config" ] || [ -L "$starship_config" ] \
      || ! grep -q '^\[directory\]' "$starship_config"; then
      run install -D -m 644 ${../config/starship/starship.toml} "$starship_config"
    fi
  '';
}
