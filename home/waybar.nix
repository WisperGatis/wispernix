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
        format = "{icon}";
        # Chaque écran a 1-10 : les ids 11-20 (second écran) s'affichent comme 1-10.
        format-icons = {
          "1" = "1"; "2" = "2"; "3" = "3"; "4" = "4"; "5" = "5";
          "6" = "6"; "7" = "7"; "8" = "8"; "9" = "9"; "10" = "10";
          "11" = "1"; "12" = "2"; "13" = "3"; "14" = "4"; "15" = "5";
          "16" = "6"; "17" = "7"; "18" = "8"; "19" = "9"; "20" = "10";
        };
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
