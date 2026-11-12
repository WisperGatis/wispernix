{ config, pkgs, lib, inputs, ... }:
{
  # Steam wrapped with Millennium, built from the local millennium/ flake.
  programs.steam = {
    enable = true;
    package = inputs.millennium-local.packages.${pkgs.stdenv.hostPlatform.system}.steam;
  };

  environment.systemPackages = [ inputs.millennium-local.packages.${pkgs.stdenv.hostPlatform.system}.millennium ];
}
