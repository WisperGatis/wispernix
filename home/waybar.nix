{ config, pkgs, lib, inputs, ... }:
let
  # Glyphes Nerd Font écrits en échappement JSON pour éviter qu'ils soient perdus.
  nixIcon = builtins.fromJSON ''""'';
  wallIcon = builtins.fromJSON ''""'';
  # Glyphe Nerd Font à partir de son code hexadécimal (ex. "f028").
  icon = hex: builtins.fromJSON ''"\u${hex}"'';
  btIcon = builtins.fromJSON ''""'';

  # Chemins absolus : Waybar n'hérite pas forcément du PATH de la session.
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  hyprctl = "${pkgs.unstable.hyprland}/bin/hyprctl";
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

      modules-left = [ "custom/nix" "hyprland/workspaces" "custom/record" "cpu" "memory" ];
      modules-center = [ "clock" "custom/wallpaper" ];
      modules-right = [ "custom/notification" "idle_inhibitor" "hyprland/language" "power-profiles-daemon" "network" "pulseaudio#mic" "pulseaudio" "bluetooth" "tray" ];

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
        # Cinq workspaces toujours visibles ; la molette passe au précédent / suivant.
        persistent-workspaces = { "*" = 5; };
        on-scroll-up = "${hyprctl} dispatch 'hl.dsp.focus({ workspace = \"e-1\" })'";
        on-scroll-down = "${hyprctl} dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'";
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

      # Survol : calendrier du mois (molette = mois suivant / précédent).
      # Clic gauche : date complète ; clic droit : calendrier interactif (calendar-popup).
      # Le tooltip est en Pango : les couleurs sont en dur (Catppuccin Mocha), pas celles de Matugen.
      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%A %d %B %Y}";
        tooltip-format = "<tt>{calendar}</tt>";
        calendar = {
          mode = "month";
          weeks-pos = "left";
          on-scroll = 1;
          format = {
            months = "<span color='#f5e0dc'><b>{}</b></span>";
            weeks = "<span color='#6c7086'>{}</span>";
            weekdays = "<span color='#f9e2af'><b>{}</b></span>";
            days = "<span color='#cdd6f4'>{}</span>";
            today = "<span color='#f38ba8'><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
        on-click-right = "calendar-popup";
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

      # Sortie audio : molette = volume (par pas de 5 %), clic droit = muet, clic milieu = pavucontrol.
      pulseaudio = {
        format = "{icon} {volume}%";
        format-bluetooth = "{icon} {volume}%";
        format-muted = "${icon "f026"}";
        format-icons = {
          default = [ (icon "f026") (icon "f027") (icon "f028") ];
          headphone = icon "f025";
          headset = icon "f025";
        };
        scroll-step = 5;
        tooltip-format = "{desc}";
        on-click = "pavucontrol";
        on-click-middle = "pavucontrol";
        on-click-right = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      # Micro : clic = muet, molette = volume d'entrée, clic droit = pavucontrol.
      "pulseaudio#mic" = {
        format = "{format_source}";
        format-muted = "{format_source}";
        format-source = "${icon "f130"} {volume}%";
        format-source-muted = "${icon "f131"}";
        tooltip-format = "{source_desc}";
        on-click = "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        on-click-right = "pavucontrol";
        on-scroll-up = "${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 5%+";
        on-scroll-down = "${wpctl} set-volume @DEFAULT_AUDIO_SOURCE@ 5%-";
      };

      tray = {
        spacing = 8;
      };
    };

    style = ../config/waybar/style.css;
  };
}
