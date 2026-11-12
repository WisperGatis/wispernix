{ config, pkgs, lib, inputs, ... }:
{
  # Plain Steam. Millennium is disabled until upstream fixes its Steam injection
  # (see issue #38).
  programs.steam.enable = true;
}
