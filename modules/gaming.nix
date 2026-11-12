{ config, pkgs, lib, inputs, ... }:
{
  programs.steam.enable = true;

  # Millennium (unstable.millennium) is disabled for now: its npm dependency
  # hash in nixpkgs-unstable doesn't match, so the build fails.
  # environment.systemPackages = [ pkgs.unstable.millennium ];
}
