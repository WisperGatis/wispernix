{ config, pkgs, lib, inputs, ... }:
{
  # storage optimizations cuz holy shit
  nix.settings.auto-optimise-store = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-40.10.5"
    "ladybird-0-unstable-2026-06-05"
    "openssl-1.1.1w"
  ];
}
