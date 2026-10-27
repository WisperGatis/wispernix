{ config, pkgs, lib, inputs, ... }:
{
  # Starship : Nix installe le binaire et l'initialise dans fish.
  # La configuration ~/.config/starship.toml est un vrai fichier géré par
  # Noctalia (voir config/starship/template.toml pour le template à copier),
  # donc Nix ne crée jamais de lien symbolique dessus.
  home.packages = [ pkgs.starship ];

  programs.fish.interactiveShellInit = lib.mkAfter ''
    starship init fish | source
  '';
}
