{ config, pkgs, lib, inputs, ... }:
{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Bluetooth : pilote, démarrage à l'allumage, et Blueman pour le panneau graphique.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
}
