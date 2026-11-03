{ config, pkgs, lib, inputs, ... }:
let
  # Glyphes Nerd Font écrits en échappement JSON pour éviter qu'ils soient perdus.
  nixIcon = builtins.fromJSON ''""'';
  wallIcon = builtins.fromJSON ''""'';
  # Glyphe Nerd Font à partir de son code hexadécimal (ex. "f028").
  icon = hex: builtins.fromJSON ''"\u${hex}"'';
  btIcon = builtins.fromJSON ''""'';
  # Barre des fenêtres : un second processus Waybar, caché au démarrage.
  # Le bouton de la barre principale l'affiche ou la cache via SIGUSR1.
  waybarTaskbar = pkgs.writeShellApplication {
    name = "waybar-taskbar";
    runtimeInputs = [ pkgs.waybar ];
    text = ''
      echo $$ > "''${XDG_RUNTIME_DIR:-/tmp}/waybar-taskbar.pid"
      exec waybar -c "$HOME/.config/waybar/taskbar.json" -s "$HOME/.config/waybar/style.css"
    '';
  };

  taskbarToggle = pkgs.writeShellApplication {
    name = "taskbar-toggle";
    text = ''
      pid=$(cat "''${XDG_RUNTIME_DIR:-/tmp}/waybar-taskbar.pid" 2>/dev/null) || exit 0
      kill -USR1 "$pid"
    '';
  };
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

      modules-left = [ "custom/nix" "hyprland/workspaces" "custom/tasks" "custom/record" "cpu" "memory" ];
      modules-center = [ "clock" "custom/wallpaper" ];
      modules-right = [ "custom/notification" "idle_inhibitor" "hyprland/language" "power-profiles-daemon" "network" "pulseaudio" "bluetooth" "tray" ];

      # État de SwayNotificationCenter : nombre de notifications et mode Ne pas déranger.
      # Clic gauche : centre de notifications ; clic droit : ne pas déranger.
      "custom/notification" = {
        exec = "swaync-client -swb";
        exec-if = "which swaync-client";
        return-type = "json";
        escape = true;
        on-click = "swaync-client -t -sw";
        on-click-right = "swaync-client -d -sw";
      };

      "custom/nix" = {
        format = nixIcon;
        tooltip = false;
        on-click-right = "session-menu";
      };

      "hyprland/workspaces" = {
        all-outputs = false;
        format = "{name}";
        on-click = "activate";
      };

      # Bouton qui affiche ou cache la barre des fenêtres.
      "custom/tasks" = {
        format = icon "f2d0";
        tooltip-format = "Fenêtres ouvertes";
        on-click = "taskbar-toggle";
      };

      "custom/record" = {
        exec = "screen-record status";
        return-type = "json";
        interval = 2;
        on-click = "screen-record toggle";
      };

      cpu = {
        format = " {usage}%";
        tooltip-format = "CPU {usage}% ({load} de charge)";
        interval = 2;
      };

      memory = {
        format = " {percentage}%";
        tooltip-format = "RAM {used:0.1f}G / {total:0.1f}G";
        interval = 2;
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

      bluetooth = {
        format = btIcon;
        format-connected = "{icon} {num_connections}";
        format-disabled = "";
        tooltip-format = "{controller_alias}\t{controller_address}";
        tooltip-format-connected = "{device_enumerate}";
        on-click = "blueman-manager";
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = icon "f06e";
          deactivated = icon "f070";
        };
        tooltip-format-activated = "Veille bloquée";
        tooltip-format-deactivated = "Veille autorisée";
      };

      "hyprland/language" = {
        format = "{short}";
      };

      "power-profiles-daemon" = {
        format = "{icon}";
        tooltip-format = "Profil : {profile}";
        format-icons = {
          performance = icon "f0e7";
          balanced = icon "f24e";
          power-saver = icon "f06c";
        };
      };

      network = {
        format-wifi = "${icon "f1eb"} {signalStrength}%";
        format-ethernet = "${icon "f0e8"} {ipaddr}";
        format-disconnected = "${icon "f071"}";
        tooltip-format = "{ifname} : {ipaddr}";
        on-click = "nm-connection-editor";
      };

      pulseaudio = {
        format = "${icon "f028"} {volume}%";
        format-muted = "${icon "f026"}";
        tooltip-format = "{desc}";
        on-click = "pavucontrol";
      };

      tray = {
        spacing = 8;
      };
    };

    style = ../config/waybar/style.css;
  };

  xdg.configFile."waybar/taskbar.json".text = builtins.toJSON [
    {
      layer = "top";
      position = "top";
      height = 28;
      margin-top = 28;
      exclusive = false;
      start_hidden = true;
      modules-left = [ "wlr/taskbar" ];
      "wlr/taskbar" = {
        all-outputs = false;
        icon-size = 16;
        tooltip = true;
        on-click = "activate";
        on-click-middle = "close";
      };
    }
  ];

  home.packages = [ waybarTaskbar taskbarToggle ];
}
