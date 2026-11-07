{ config, pkgs, lib, inputs, ... }:
{
  #Umbriel enableFishIntegration
  xdg.configFile."umbriel/config.toml".source = ../config/umbriel/config.toml;
  # Shaders d'écran d'Umbriel (presets déclarés dans config.toml).
  xdg.configFile."umbriel/effects" = { source = ../config/umbriel/effects; recursive = true; };

  # Mod+L: flip EVERY workspace between scrolling and master (Umbriel's
  # workspace-set-layout only touches the active workspace, so this visits each one).
  # Remembers the global state in ~/.local/state/umbriel/layout-mode.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "umbriel-layout-toggle-all";
      runtimeInputs = [ pkgs.jq pkgs.coreutils ];
      text = ''
        state=$HOME/.local/state/umbriel/layout-mode
        mkdir -p "$(dirname "$state")"
        cur=$(cat "$state" 2>/dev/null || echo scrolling)
        if [ "$cur" = scrolling ]; then next=master; else next=scrolling; fi

        ws=$(umbriel workspaces --json)

        # Focused workspace, so we can return to it afterwards.
        focus=$(printf '%s' "$ws" | jq -r '.. | objects | select(has("index") and has("output") and ((.focused // .active) == true)) | "\(.index) \(.output)"' | head -n1)

        printf '%s' "$ws" \
          | jq -r '.. | objects | select(has("index") and has("output")) | "\(.index) \(.output)"' \
          | while read -r idx out; do
              umbriel msg workspace-switch "$idx" --output "$out"
              umbriel msg workspace-set-layout "$next"
            done

        if [ -n "$focus" ]; then
          read -r fidx fout <<< "$focus"
          umbriel msg workspace-switch "$fidx" --output "$fout"
        fi

        printf '%s\n' "$next" > "$state"
      '';
    })
  ];

  # dux imports (previously dank-material-shell.)
  #imports = [ inputs.dms.homeModules.dank-material-shell ];

  home.file.".local/bin/polkit-gnome-agent" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh
      exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
    '';
  };

  xdg.configFile = {
    "niri/config.kdl" = {
      source = ../config/niri/config.kdl;
      force = true;
    };

    "niri/monitors.kdl" = {
      source = ../config/niri/monitors.kdl;
      force = true;
    };

    "mango/config.toml" = {
      source = ../config/mango/config.toml;
      force = true;
    };
  };

  # labwc config path.
  xdg.configFile."labwc" = {
    source = ../config/labwc;
    executable = true;
    recursive = true;
  };

  # sway config path.
  xdg.configFile."sway" = {
    source = ../config/sway;
    executable = true;
    recursive = true;
  };

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enable-extensions = [
        "dash-to-dock@micxgx.gmail.com"
      ];
    };
  };
}
