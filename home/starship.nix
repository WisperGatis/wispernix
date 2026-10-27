{ config, pkgs, lib, inputs, ... }:
{
  # Starship : Noctalia gère ~/.config/starship.toml (bloc de palette entre
  # les marqueurs NOCTALIA STARSHIP PALETTE). Nix ne crée ni ne modifie ce
  # fichier : on installe seulement starship et on l'initialise dans fish.
  home.packages = [ pkgs.starship ];

  programs.fish.interactiveShellInit = lib.mkAfter ''
    starship init fish | source
  '';
}
