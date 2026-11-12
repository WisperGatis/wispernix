{ config, pkgs, lib, inputs, ... }:
{
  programs.steam.enable = true;

  # Millennium, built from the local millennium/ flake with a corrected hash.
  environment.systemPackages = [ inputs.millennium-local.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
