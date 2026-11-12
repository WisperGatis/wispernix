{ config, pkgs, lib, inputs, ... }:
{
  # Plain Steam. The Millennium preload stops Steam from launching
  # (verified: Steam runs once the preload is removed). The Millennium
  # package stays in millennium/ for when the injection is fixed.
  programs.steam.enable = true;
}
