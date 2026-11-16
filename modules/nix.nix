{ config, pkgs, lib, inputs, ... }:
{
  # storage optimizations cuz holy shit
  nix.settings.auto-optimise-store = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-40.10.5"
    # Needed by linux-wallpaper-engine (jagrat7 flake pins Electron 39, EOL).
    "electron-39.8.10"
    "ladybird-0-unstable-2026-06-05"
    "openssl-1.1.1w"
  ];
}
