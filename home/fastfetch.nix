{ config, pkgs, lib, ... }:
{
  # fastfetch: pixel-art emblem logo (half-block ANSI art in config/fastfetch).
  # The logo is referenced as a Nix store path so it works without any
  # ~ expansion inside fastfetch itself.
  # Software-only profile, run with: fastfetch -c software
  xdg.configFile."fastfetch/software.jsonc".source = ../config/fastfetch/software.jsonc;

  # fetch-box: pixel-art emblem with the software specs framed in boxes next
  # to it (fastfetch can't draw borders, so config/fastfetch/box.py does it).
  home.packages = [
    (pkgs.writeShellScriptBin "fetch-box" ''
      exec ${pkgs.python3}/bin/python3 ${../config/fastfetch/box.py} \
        ${../config/fastfetch/logo.txt} \
        "$HOME/.config/fastfetch/software.jsonc" \
        ${pkgs.fastfetch}/bin/fastfetch
    '')
  ];

  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        type = "file-raw";
        source = "${../config/fastfetch/logo.txt}";
        padding = {
          top = 1;
          left = 2;
          right = 4;
        };
      };

      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "display"
        "de"
        "wm"
        "terminal"
        "cpu"
        "gpu"
        "memory"
        "break"
        "colors"
      ];
    };
  };
}
