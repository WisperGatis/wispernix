{ config, pkgs, lib, inputs, ... }:
let
  home = config.home.homeDirectory;
  wallpaperDir = "${home}/Pictures/Wallpapers";
  recordDir = "${home}/Videos/Recordings";
  flakeDir = "${home}/wispernix";

  # Rofi lit le thème et les couleurs générées par Matugen.
  rofiTheme = "${home}/.config/rofi/theme.rasi";

  # Choisit clair ou sombre, puis un fond d'écran ; Matugen régénère les couleurs.
  wallpaperMenu = pkgs.writeShellApplication {
    name = "wallpaper-menu";
    runtimeInputs = [ pkgs.rofi pkgs.swww pkgs.matugen pkgs.findutils pkgs.coreutils ];
    text = ''
      mode=$(printf 'dark\nlight\n' | rofi -dmenu -p "Thème" -theme ${rofiTheme}) || exit 0
      img=$(find "${wallpaperDir}" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%f\n' | sort | rofi -dmenu -p "Fond d'écran" -theme ${rofiTheme}) || exit 0
      [ -n "$img" ] || exit 0
      path="${wallpaperDir}/$img"
      swww img "$path" --transition-type grow
      matugen image "$path" --mode "$mode"
      pkill -SIGUSR2 waybar || true
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

  # Compare le système actuel à ce que le flake construirait ; affiche si une mise à jour est nécessaire.
  storeStatus = pkgs.writeShellApplication {
    name = "store-status";
    runtimeInputs = [ pkgs.nix pkgs.gnugrep pkgs.coreutils ];
    text = ''
      if out=$(nix build --dry-run --no-link "${flakeDir}#nixosConfigurations.nixos.config.system.build.toplevel" 2>&1); then
        n=$(printf '%s\n' "$out" | grep -c '\.drv$' || true)
        if [ "$n" -eq 0 ]; then
          printf '{"text":"","class":"current","tooltip":"Systeme a jour"}\n'
        else
          printf '{"text":"%s","class":"update","tooltip":"%s derivations a reconstruire : lancer nixos-rebuild"}\n' "$n" "$n"
        fi
      else
        printf '{"text":"?","class":"error","tooltip":"Evaluation du flake impossible"}\n'
      fi
    '';
  };
in
{
  # Hyprland : le fichier Lua est dans le dépôt et lié par Nix.
  # Le module HM Hyprland est désactivé pour éviter qu'il génère son propre hyprland.lua.
  wayland.windowManager.hyprland.enable = false;

  xdg.configFile."hypr/hyprland.lua".source = ../config/hyprland/hyprland.lua;

  # Rofi : menu de lancement, thème Matugen.
  xdg.configFile."rofi/config.rasi".text = ''
    configuration {
      modi: "drun,run,window";
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

  home.packages = [
    wallpaperMenu
    screenRecord
    storeStatus
    pkgs.rofi
    pkgs.swww
    pkgs.wf-recorder
    pkgs.libnotify
    pkgs.matugen
  ];
}
