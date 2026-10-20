{ config, pkgs, lib, inputs, ... }:
{
  services.flatpak.enable = true;

  services.printing.enable = true;
}
