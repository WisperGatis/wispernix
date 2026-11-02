{ config, pkgs, lib, inputs, ... }:
let
  # Glyphes Nerd Font écrits en échappement JSON pour éviter qu'ils soient perdus.
  nixIcon = builtins.fromJSON ''""'';
  wallIcon = builtins.fromJSON ''""'';
in
{
  programs.waybar = {
    enable = true;
    # Lancée par Hyprland (exec dans hyprland.lua), pas par systemd.
    systemd.enable = false;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 28;
      spacing = 0;
      # Barre pleine largeur, collée au bord supérieur. Affichée sur chaque écran.
      margin-top = 0;
      margin-left = 0;
      margin-right = 0;

      modules-left = [ "custom/nix" "hyprland/workspaces" "custom/record" ];
      modules-center = [ "clock" "custom/wallpaper" ];
      modules-right = [ "tray" ];

      "custom/nix" = {
        format = nixIcon;
        tooltip = false;
      };

      "hyprland/workspaces" = {
        all-outputs = false;
        format = "{name}";
        on-click = "activate";
      };

      "custom/record" = {
        exec = "screen-record status";
        return-type = "json";
        interval = 2;
        on-click = "screen-record toggle";
      };

      clock = {
        format = "{:%H:%M}";
        tooltip-format = "{:%A %d %B %Y}";
      };

      "custom/wallpaper" = {
        format = wallIcon;
        tooltip-format = "Fond d'écran et thème";
        on-click = "wallpaper-menu";
      };

      tray = {
        spacing = 8;
      };
    };

    style = ../config/waybar/style.css;
  };
}
