{ config, pkgs, lib, inputs, ... }:
{
  services.flatpak.enable = true;

  services.printing.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
  };
}
