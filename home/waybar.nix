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
  playerctl = "${pkgs.playerctl}/bin/playerctl";
in
{
  programs.waybar = {
    enable = true;
    # Lancée par Hyprland (exec dans hyprland.lua), pas par systemd.
    systemd.enable = false;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 26;
      spacing = 4;
      # Barre pleine largeur, avec les espaces de travail au centre de l'écran.
      margin-top = 0;
      margin-left = 0;
      margin-right = 0;
      fixed-center = true;

      modules-left = [ "custom/nix" "custom/cpu" "pulseaudio" "mpris" "hyprland/language" ];
      modules-center = [ "hyprland/workspaces" ];
      modules-right = [ "custom/record" "custom/gpu" "network" "pulseaudio#mic" "bluetooth" "power-profiles-daemon" "custom/wallpaper" "idle_inhibitor" "tray" "clock" "custom/memory" "custom/notification" "custom/power" ];

      "hyprland/window" = {
        format = "{title}";
        max-length = 38;
        separate-outputs = true;
      };

      "custom/power" = {
        align = 0.5;
        format = "⏻";
        tooltip-format = "Menu de session";
        on-click = "session-menu";
      };

      # État de SwayNotificationCenter : nombre de notifications et mode Ne pas déranger.
      # Clic gauche : centre de notifications ; clic droit : ne pas déranger.
      "custom/notification" = {
        align = 0.5;
        exec = "swaync-client -swb";
        exec-if = "which swaync-client";
        return-type = "json";
        escape = true;
        on-click = "swaync-client -t -sw";
        on-click-right = "swaync-client -d -sw";
      };

      "custom/nix" = {
        align = 0.5;
        format = nixIcon;
        tooltip = false;
        on-click-right = "session-menu";
      };

      "hyprland/workspaces" = {
        all-outputs = false;
        format = "{icon}";
        format-icons = {
          active = "●";
          urgent = "●";
          default = "󰊠";
        };
        on-click = "activate";
        # Huit icônes visibles ; la molette passe au précédent / suivant.
        persistent-workspaces = { "*" = 8; };
        on-scroll-up = "${hyprctl} dispatch 'hl.dsp.focus({ workspace = \"e-1\" })'";
        on-scroll-down = "${hyprctl} dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'";
      };

      "custom/record" = {
        align = 0.5;
        exec = "screen-record status";
        return-type = "json";
        interval = 2;
        on-click = "screen-record toggle";
      };

      "custom/cpu" = {
        align = 0.5;
        format = "${icon "f2db"} {text}";
        # hw-monitor (config/waybar/hw-monitor.py) imprime une ligne JSON toutes les 2 s :
        # classes warning / critical selon l'usage et la température, détails dans le tooltip.
        exec = "hw-monitor cpu";
        return-type = "json";
        escape = false;
        on-click = "kitty -e btop";
      };

      "custom/memory" = {
        align = 0.5;
        format = "${icon "f080"} {text}";
        exec = "hw-monitor memory";
        return-type = "json";
        escape = false;
        on-click = "kitty -e btop";
      };

      # GPU AMD (masqué automatiquement si aucune carte amdgpu n'est trouvée).
      "custom/gpu" = {
        align = 0.5;
        format = "${icon "f26c"} {text}";
        exec = "hw-monitor gpu";
        return-type = "json";
        escape = false;
        on-click = "kitty -e btop";
      };

      # Survol : calendrier du mois (molette = mois suivant / précédent).
      # Clic gauche : date complète ; clic droit : calendrier interactif (calendar-popup).
      # Le tooltip est en Pango : les couleurs sont en dur (Catppuccin Mocha), pas celles de Matugen.
      clock = {
        align = 0.5;
        format = "{:%I:%M %p | %d-%b-%Y} 󰃭";
        interval = 60;
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

      # Lecteur de musique (MPRIS : Spotify, navigateurs...). Masqué quand rien ne joue.
      # Clic : lecture / pause ; clic droit : suivant ; clic milieu : précédent ; molette : suivant / précédent.
      mpris = {
        align = 0.5;
        format = "{player_icon} {title}";
        format-paused = "{status_icon} {title}";
        title-len = 28;
        max-length = 34;
        player-icons = {
          default = icon "f001";
          spotify = icon "f1bc";
          firefox = icon "f269";
        };
        status-icons = {
          playing = icon "f04b";
          paused = icon "f04c";
        };
        tooltip-format = "{player} : {artist} - {title}\n{album}";
        on-click = "play-pause";
        on-click-right = "next";
        on-click-middle = "previous";
        on-scroll-up = "${playerctl} next";
        on-scroll-down = "${playerctl} previous";
      };

      "custom/wallpaper" = {
        align = 0.5;
        format = wallIcon;
        tooltip-format = "Fond d'écran et thème";
        on-click = "wallpaper-menu";
      };

      bluetooth = {
        align = 0.5;
        format = btIcon;
        format-connected = "{icon} {num_connections}";
        format-disabled = "";
        tooltip-format = "{controller_alias}\t{controller_address}";
        tooltip-format-connected = "{device_enumerate}";
        on-click = "blueman-manager";
      };

      idle_inhibitor = {
        align = 0.5;
        format = "{icon}";
        format-icons = {
          activated = icon "f06e";
          deactivated = icon "f070";
        };
        tooltip-format-activated = "Veille bloquée";
        tooltip-format-deactivated = "Veille autorisée";
      };

      "hyprland/language" = {
        align = 0.5;
        format = "{short}";
      };

      "power-profiles-daemon" = {
        align = 0.5;
        format = "{icon}";
        tooltip-format = "Profil : {profile}";
        format-icons = {
          performance = icon "f0e7";
          balanced = icon "f24e";
          power-saver = icon "f06c";
        };
      };

      network = {
        align = 0.5;
        format-wifi = "${icon "f1eb"} {signalStrength}%";
        format-ethernet = "${icon "f0e8"} {ipaddr}";
        format-disconnected = "${icon "f071"}";
        tooltip-format = "{ifname} : {ipaddr}";
        on-click = "nm-connection-editor";
      };

      # Sortie audio : molette = volume (par pas de 5 %), clic droit = muet, clic milieu = pavucontrol.
      pulseaudio = {
        align = 0.5;
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
        align = 0.5;
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
