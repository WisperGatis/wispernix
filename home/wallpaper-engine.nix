{ config, pkgs, lib, ... }:

# GUI-free fallback for linux-wallpaperengine.
#
# The GUIs are flaky on NixOS, so this drives the CLI directly:
#
#   wpe list                 list workshop wallpapers you have downloaded
#   wpe set <id|path> [...]  set a wallpaper (extra args go to the CLI)
#   wpe restore             re-apply the last wallpaper (also runs at login)
#   wpe stop                 kill the running renderer
#   wpe props <id|path>      show the wallpaper's tweakable properties
#   wpe help                 usage
#
# Env overrides:
#   WPE_ASSETS_DIR  Wallpaper Engine "assets" folder (auto-detected below)
#   WPE_WORKSHOP    workshop content folder (auto-detected below)
#   WPE_SCREEN      output name, e.g. DP-1 (default: all outputs)
#   WPE_EXTRA       extra args appended to every set, e.g. "--fps 30 --silent"

let
  wpe = pkgs.writeShellApplication {
    name = "wpe";
    runtimeInputs = [ pkgs.coreutils pkgs.procps pkgs.findutils ];
    text = ''
      # linux-wallpaperengine comes from the system profile (modules/packages.nix).
      export PATH="/run/current-system/sw/bin:$PATH"

      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/wpe"
      state_file="$state_dir/last"

      # Steam library roots, so we can find the Wallpaper Engine install and
      # the workshop folder wherever Steam (or a Flatpak Steam) put them.
      steam_roots=(
        "$HOME/.local/share/Steam"
        "$HOME/.steam/steam"
        "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"
      )

      find_assets() {
        if [ -n "''${WPE_ASSETS_DIR:-}" ]; then
          printf '%s\n' "$WPE_ASSETS_DIR"; return
        fi
        for root in "''${steam_roots[@]}"; do
          if [ -d "$root/steamapps/common/wallpaper_engine/assets" ]; then
            printf '%s\n' "$root/steamapps/common/wallpaper_engine/assets"; return
          fi
        done
        return 1
      }

      find_workshop() {
        if [ -n "''${WPE_WORKSHOP:-}" ]; then
          printf '%s\n' "$WPE_WORKSHOP"; return
        fi
        for root in "''${steam_roots[@]}"; do
          d="$root/steamapps/workshop/content/431960"
          if [ -d "$d" ]; then printf '%s\n' "$d"; return; fi
        done
        return 1
      }

      need_assets() {
        if ! assets="$(find_assets)"; then
          echo "wpe: could not find Wallpaper Engine's assets folder (Steam app 431960)." >&2
          echo "     Set WPE_ASSETS_DIR to the 'assets' folder inside wallpaper_engine." >&2
          exit 1
        fi
      }

      # Turn an ID into a path under the workshop folder; pass real paths through.
      resolve() {
        target="$1"
        if [ -e "$target" ]; then
          realpath "$target"; return
        fi
        if workshop="$(find_workshop)" && [ -d "$workshop/$target" ]; then
          printf '%s\n' "$workshop/$target"; return
        fi
        echo "wpe: no wallpaper found for '$target'" >&2
        exit 1
      }

      stop_renderer() {
        pkill -x linux-wallpaper || true
        pkill -f 'linux-wallpaperengine' || true
      }

      apply() {
        need_assets
        target="$(resolve "$1")"
        shift
        screen_args=()
        if [ -n "''${WPE_SCREEN:-}" ]; then
          screen_args=(--screen-root "$WPE_SCREEN")
        fi
        # shellcheck disable=SC2206
        extra=(''${WPE_EXTRA:-})

        stop_renderer
        mkdir -p "$state_dir"
        # Remember the request so `wpe restore` can replay it after a reboot.
        printf '%s\n' "$target" > "$state_file"
        : > "$state_file.args"
        if [ $# -gt 0 ]; then printf '%s\n' "$@" > "$state_file.args"; fi

        # Detach from the terminal so the renderer keeps running after we exit.
        nohup linux-wallpaperengine --assets-dir "$assets" "''${screen_args[@]}" \
          "''${extra[@]}" "$@" "$target" >"$state_dir/renderer.log" 2>&1 &
        disown
        echo "wpe: now showing $target (log: $state_dir/renderer.log)"
      }

      cmd="''${1:-help}"
      shift || true

      case "$cmd" in
        list)
          need_assets >/dev/null
          workshop="$(find_workshop)" || { echo "wpe: no workshop folder yet, subscribe to wallpapers in Steam first." >&2; exit 1; }
          for d in "$workshop"/*/; do
            [ -d "$d" ] || continue
            id="$(basename "$d")"
            title="$(sed -n 's/.*"title"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$d/project.json" 2>/dev/null | head -n1)"
            printf '%-14s %s\n' "$id" "''${title:-?}"
          done
          ;;
        set)
          [ $# -ge 1 ] || { echo "usage: wpe set <id|path> [cli args...]" >&2; exit 1; }
          apply "$@"
          ;;
        restore)
          [ -f "$state_file" ] || { echo "wpe: nothing saved yet, run 'wpe set' first." >&2; exit 0; }
          target="$(cat "$state_file")"
          args=()
          if [ -s "$state_file.args" ]; then
            mapfile -t args < "$state_file.args"
          fi
          apply "$target" "''${args[@]}"
          ;;
        stop)
          stop_renderer
          echo "wpe: stopped."
          ;;
        props)
          [ $# -ge 1 ] || { echo "usage: wpe props <id|path>" >&2; exit 1; }
          need_assets
          target="$(resolve "$1")"
          linux-wallpaperengine --assets-dir "$assets" --list-properties "$target"
          ;;
        help|-h|--help)
          cat <<'EOF'
wpe list                 list downloaded workshop wallpapers
wpe set <id|path> [...]  set a wallpaper, extra args go to the CLI
wpe restore              re-apply the last wallpaper
wpe stop                 kill the renderer
wpe props <id|path>      show tweakable properties
EOF
          ;;
        *)
          echo "wpe: unknown command '$cmd'" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  home.packages = [ wpe ];

  # Restore the last wallpaper at login. Runs after the graphical session is up
  # so the renderer has a Wayland/X display to draw on.
  systemd.user.services.wpe-restore = {
    Unit = {
      Description = "Restore last linux-wallpaperengine wallpaper";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = false;
      ExecStart = "${wpe}/bin/wpe restore";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
