{ config, pkgs, lib, inputs, ... }:
let
  home = config.home.homeDirectory;
  wallpaperDir = "${home}/Pictures/Wallpapers";
  recordDir = "${home}/Videos/Recordings";
  screenshotDir = "${home}/Pictures/Screenshots";

  # Rofi avec le plugin emoji.
  rofi = pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; };

  # Rofi lit le thème et les couleurs générées par Matugen.
  rofiTheme = "${home}/.config/rofi/theme.rasi";

  # Palettes classiques (valeurs des thèmes publiés). Chacune produit colors.css (Waybar)
  # et colors.rasi (Rofi), avec les mêmes noms que les modèles Matugen.
  palettes = {
    catppuccin-mocha = { primary = "#f5e0dc"; on_primary = "#1e1e2e"; surface = "#1e1e2e"; on_surface = "#cdd6f4"; surface_variant = "#313244"; tertiary = "#f9e2af"; error = "#f38ba8"; };
    catppuccin-latte = { primary = "#dc8a78"; on_primary = "#eff1f5"; surface = "#eff1f5"; on_surface = "#4c4f69"; surface_variant = "#ccd0da"; tertiary = "#df8e1d"; error = "#d20f39"; };
    gruvbox-dark = { primary = "#fabd2f"; on_primary = "#282828"; surface = "#282828"; on_surface = "#ebdbb2"; surface_variant = "#3c3836"; tertiary = "#b8bb26"; error = "#fb4934"; };
    nord = { primary = "#88c0d0"; on_primary = "#2e3440"; surface = "#2e3440"; on_surface = "#d8dee9"; surface_variant = "#3b4252"; tertiary = "#a3be8c"; error = "#bf616a"; };
    rose-pine = { primary = "#c4a7e7"; on_primary = "#191724"; surface = "#191724"; on_surface = "#e0def4"; surface_variant = "#26233a"; tertiary = "#f6c177"; error = "#eb6f92"; };
    dracula = { primary = "#bd93f9"; on_primary = "#282a36"; surface = "#282a36"; on_surface = "#f8f8f2"; surface_variant = "#44475a"; tertiary = "#f1fa8c"; error = "#ff5555"; };
    tokyo-night = { primary = "#7aa2f7"; on_primary = "#1a1b26"; surface = "#1a1b26"; on_surface = "#c0caf5"; surface_variant = "#292e42"; tertiary = "#9ece6a"; error = "#f7768e"; };
    solarized-dark = { primary = "#268bd2"; on_primary = "#002b36"; surface = "#002b36"; on_surface = "#839496"; surface_variant = "#073642"; tertiary = "#859900"; error = "#dc322f"; };
  };

  waybarCss = p: ''
    @define-color primary ${p.primary};
    @define-color on_primary ${p.on_primary};
    @define-color surface ${p.surface};
    @define-color on_surface ${p.on_surface};
    @define-color tertiary ${p.tertiary};
    @define-color error ${p.error};
  '';

  rofiRasi = p: ''
    * {
        primary: ${p.primary};
        on-primary: ${p.on_primary};
        surface: ${p.surface};
        on-surface: ${p.on_surface};
        surface-variant: ${p.surface_variant};
    }
  '';

  paletteDir = pkgs.linkFarm "palettes" (lib.concatLists (lib.mapAttrsToList (slug: p: [
    { name = "${slug}/colors.css"; path = pkgs.writeText "${slug}-colors.css" (waybarCss p); }
    { name = "${slug}/colors.rasi"; path = pkgs.writeText "${slug}-colors.rasi" (rofiRasi p); }
  ]) palettes));

  # Fond d'écran : choix du thème (Matugen clair/sombre ou palette), puis image en grille de miniatures.
  wallpaperMenu = pkgs.writeShellApplication {
    name = "wallpaper-menu";
    runtimeInputs = [ rofi pkgs.awww pkgs.matugen pkgs.findutils pkgs.coreutils ];
    text = ''
      grid='listview { columns: 4; lines: 3; } element { orientation: vertical; } element-icon { size: 9em; }'
      theme=$(printf 'Matugen sombre\nMatugen clair\n%s\n' "$(ls ${paletteDir})" | rofi -dmenu -p "Thème" -theme ${rofiTheme}) || exit 0
      case "$theme" in
        "Matugen sombre") mode=dark ;;
        "Matugen clair") mode=light ;;
        *) mode="" ;;
      esac
      # Chaque entrée affiche le nom et une miniature (\0icon).
      img=$(find "${wallpaperDir}" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) \
        -printf '%f\0icon\x1f%p\n' | sort | rofi -dmenu -show-icons -p "Fond d'écran" \
        -theme ${rofiTheme} -theme-str "$grid") || exit 0
      [ -n "$img" ] || exit 0
      path="${wallpaperDir}/$img"
      awww img "$path" --transition-type grow
      if [ -n "$mode" ]; then
        matugen image "$path" --mode "$mode"
      else
        [ -d "${paletteDir}/$theme" ] || exit 1
        install -D -m 644 "${paletteDir}/$theme/colors.css" "$HOME/.config/waybar/colors.css"
        install -D -m 644 "${paletteDir}/$theme/colors.rasi" "$HOME/.config/rofi/colors.rasi"
      fi
      pkill -SIGUSR2 waybar || true
    '';
  };

  # Historique du presse-papiers (alimenté par wl-paste/cliphist au démarrage de Hyprland).
  clipboardMenu = pkgs.writeShellApplication {
    name = "clipboard-menu";
    runtimeInputs = [ rofi pkgs.cliphist pkgs.wl-clipboard ];
    text = ''
      entry=$(cliphist list | rofi -dmenu -p "Presse-papiers" -theme ${rofiTheme}) || exit 0
      [ -n "$entry" ] || exit 0
      printf '%s' "$entry" | cliphist decode | wl-copy
    '';
  };

  # Captures : région, écran entier, fenêtre active, ou menu. Copie dans le presse-papiers.
  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = [ pkgs.grim pkgs.slurp pkgs.jq pkgs.wl-clipboard pkgs.libnotify pkgs.unstable.hyprland rofi pkgs.coreutils ];
    text = ''
      mode=''${1:-menu}
      if [ "$mode" = menu ]; then
        mode=$(printf 'region\nfull\nwindow\n' | rofi -dmenu -p "Capture" -theme ${rofiTheme}) || exit 0
      fi
      mkdir -p "${screenshotDir}"
      file="${screenshotDir}/$(date +%Y-%m-%d_%H-%M-%S).png"
      case "$mode" in
        region)
          geom=$(slurp) || exit 0
          grim -g "$geom" "$file" ;;
        full)
          grim "$file" ;;
        window)
          geom=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
          grim -g "$geom" "$file" ;;
        *) exit 0 ;;
      esac
      wl-copy < "$file"
      notify-send "Capture enregistrée" "$file"
    '';
  };

  # Menu de session (clic droit sur le logo) : verrouiller, déconnecter, redémarrer, éteindre.
  # Les actions destructives demandent une confirmation.
  sessionMenu = pkgs.writeShellApplication {
    name = "session-menu";
    runtimeInputs = [ rofi pkgs.systemd pkgs.unstable.hyprland pkgs.procps ];
    text = ''
      choice=$(printf 'Verrouiller\nDéconnexion\nRedémarrer\nÉteindre\n' | rofi -dmenu -p "Session" -theme ${rofiTheme}) || exit 0
      confirm() {
        answer=$(printf 'Non\nOui\n' | rofi -dmenu -p "$1 ?" -theme ${rofiTheme}) || return 1
        [ "$answer" = "Oui" ]
      }
      case "$choice" in
        Verrouiller) hyprlock ;;
        Déconnexion) confirm "Déconnexion" && hyprctl dispatch "hl.dsp.exit()" ;;
        Redémarrer) confirm "Redémarrer" && systemctl reboot ;;
        Éteindre) confirm "Éteindre" && systemctl poweroff ;;
      esac
    '';
  };

  # Enregistrement d'écran : bascule wf-recorder ; "status" pour Waybar.
  screenRecord = pkgs.writeShellApplication {
    name = "screen-record";
    runtimeInputs = [ pkgs.wf-recorder pkgs.procps pkgs.coreutils pkgs.libnotify ];
    text = ''
      case "''${1:-toggle}" in
        status)
          if pgrep -x wf-recorder >/dev/null; then
            printf '{"text":"REC","class":"recording","tooltip":"Enregistrement en cours"}\n'
          else
            printf '{"text":"REC","class":"idle","tooltip":"Demarrer l enregistrement"}\n'
          fi
          ;;
        toggle)
          if pgrep -x wf-recorder >/dev/null; then
            pkill -INT -x wf-recorder
            notify-send "Enregistrement sauvegardé" "${recordDir}"
          else
            mkdir -p "${recordDir}"
            wf-recorder -f "${recordDir}/$(date +%Y-%m-%d_%H-%M-%S).mp4" &
            notify-send "Enregistrement démarré"
          fi
          ;;
      esac
    '';
  };

in
{
  # Hyprland : le fichier Lua est dans le dépôt et lié par Nix.
  # Le module HM Hyprland est désactivé pour éviter qu'il génère son propre hyprland.lua.
  wayland.windowManager.hyprland.enable = false;

  xdg.configFile."hypr/hyprland.lua".source = ../config/hyprland/hyprland.lua;
  xdg.configFile."hypr/shaders/vibrance.frag".source = ../config/hyprland/shaders/vibrance.frag;

  # Rofi : menu de lancement, émojis en mode "emoji", thème Matugen.
  xdg.configFile."rofi/config.rasi".text = ''
    configuration {
      modi: "drun,run,window,emoji";
      show-icons: true;
      drun-display-format: "{name}";
    }

    @theme "${rofiTheme}"
  '';
  xdg.configFile."rofi/theme.rasi".source = ../config/rofi/theme.rasi;

  # Matugen écrit colors.rasi et colors.css ; avant le premier passage, on pose des valeurs par défaut
  # pour que Rofi et Waybar puissent lire leurs fichiers (un import manquant les bloque).
  home.activation.matugenDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rofi_colors="$HOME/.config/rofi/colors.rasi"
    waybar_colors="$HOME/.config/waybar/colors.css"
    if [ ! -e "$rofi_colors" ]; then
      run install -D -m 644 ${../config/rofi/colors-default.rasi} "$rofi_colors"
    fi
    if [ ! -e "$waybar_colors" ]; then
      run install -D -m 644 ${../config/waybar/colors-default.css} "$waybar_colors"
    fi
  '';

  # Matugen : modèles pour Waybar et Rofi.
  xdg.configFile."matugen/config.toml".source = ../config/matugen/config.toml;
  xdg.configFile."matugen/templates/waybar.css".source = ../config/matugen/templates/waybar.css;
  xdg.configFile."matugen/templates/rofi.rasi".source = ../config/matugen/templates/rofi.rasi;

  # Verrouillage et veille : hyprlock verrouille, hypridle éteint l'écran puis verrouille.
  programs.hyprlock.enable = true;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          # 10 min : écran éteint.
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          # 15 min : verrouillage.
          timeout = 900;
          on-timeout = "loginctl lock-session";
        }
      ];
    };
  };

  home.packages = [
    wallpaperMenu
    clipboardMenu
    sessionMenu
    screenshot
    screenRecord
    rofi
    pkgs.awww
    pkgs.wf-recorder
    pkgs.libnotify
    pkgs.matugen
    pkgs.hyprcursor
    pkgs.grim
    pkgs.slurp
    pkgs.cliphist
    pkgs.wl-clipboard
  ];
}
