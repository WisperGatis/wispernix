{ config, pkgs, lib, inputs, ... }:
{
  programs.steam.enable = true;

  # Millennium from nixpkgs-unstable, installed as a regular system package.
  environment.systemPackages = [ pkgs.unstable.millennium ];
}
