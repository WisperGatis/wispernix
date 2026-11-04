{ config, pkgs, lib, inputs, ... }:
{
  # Quickshell : la configuration QML est dans le dépôt et liée par Nix.
  home.packages = [ pkgs.quickshell ];

  xdg.configFile."quickshell".source = ../config/quickshell;
}
