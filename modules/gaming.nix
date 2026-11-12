{ config, pkgs, lib, inputs, ... }:
{
  # Steam with Millennium (experimental, see millennium/flake.nix).
  # Revert to plain programs.steam.enable = true if it fails to launch.
  programs.steam = {
    enable = true;
    package = inputs.millennium-local.packages.${pkgs.stdenv.hostPlatform.system}.steamWithMillennium;
  };
}
