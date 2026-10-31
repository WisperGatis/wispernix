{ config, pkgs, lib, inputs, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # Noctalia rewrites starship.toml on theme change, so it must stay a
  # writable file rather than a read-only Nix store symlink. Seed it from
  # the repo only when it is missing or still a store symlink.
  home.activation.starshipConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    starship_config="$HOME/.config/starship.toml"
    if [ ! -e "$starship_config" ] || [ -L "$starship_config" ]; then
      run install -D -m 644 ${../config/starship/starship.toml} "$starship_config"
    fi
  '';
}
