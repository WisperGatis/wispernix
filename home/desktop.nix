{ config, pkgs, lib, inputs, ... }:
{
  #Umbriel enableFishIntegration
  xdg.configFile."umbriel/config.toml".source = ../config/umbriel/config.toml;

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
