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
    settings = fromTOML (builtins.readFile ../config/starship/starship.toml);
  };
}
