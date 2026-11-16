{ config, pkgs, lib, ... }:
{
  # fastfetch: pixel-art emblem logo (half-block ANSI art in config/fastfetch).
  # The logo is referenced as a Nix store path so it works without any
  # ~ expansion inside fastfetch itself.
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
