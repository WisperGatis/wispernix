{ config, pkgs, lib, inputs, ... }:
{
  programs.steam = {
    enable = true;
    package = pkgs.millennium-steam.override {
      extraArgs = "-system-composer -cef-disable-gpu-compositing";
    };
  };
}
