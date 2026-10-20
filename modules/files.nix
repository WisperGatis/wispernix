{ config, pkgs, lib, inputs, ... }:
{
  programs.thunar = {
    enable = true;

    plugins = with pkgs.xfce; [
      pkgs.thunar-archive-plugin
      pkgs.thunar-volman
    ];
  };

  #Nécessaire hors session XFCE complète pour conserver les préférences Thunar.
  programs.xfconf.enable = true;

  #Corbeille, montages USB, réseaux et emplacements distants.
  services.gvfs.enable = true;

  #Miniatures dans Thunar.
  services.tumbler.enable = true;

}
