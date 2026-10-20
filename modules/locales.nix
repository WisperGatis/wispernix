{ config, pkgs, lib, inputs, ... }:
{
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "ch";
    variant = "fr";
  };

  console.keyMap = "fr_CH";

}
