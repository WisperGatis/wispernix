{ config, pkgs, lib, inputs, ... }:
{
  # Plain Steam. steamWithMillennium (millennium/flake.nix) still exits right
  # after the launcher, even with STEAM_RUNTIME=0. Re-enable it there once the
  # injection is fixed. Tracked in issue #38.
  programs.steam.enable = true;
}
