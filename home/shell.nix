{ config, pkgs, lib, inputs, ... }:
{
  programs.fish = {
    enable = true;

    # Tide : désactivé au profit de Starship, gardé comme fallback temporaire.
    # plugins = [
    #   {
    #     name = "tide";
    #     src = pkgs.fishPlugins.tide.src;
    #   }
    # ];

    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };
}
