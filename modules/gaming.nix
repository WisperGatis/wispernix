{ config, pkgs, lib, inputs, ... }:
{
  #Millennium to make Steam better and allowing theming.
  programs.steam = {
    enable = true;
    package = pkgs.millennium-steam.override {
      extraArgs = "-system-composer -cef-disable-gpu-compositing";
    };
  };

}
