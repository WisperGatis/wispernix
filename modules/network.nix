{ config, pkgs, lib, inputs, ... }:
{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Bloque les domaines d'analytics insightjs.
  networking.extraHosts = ''
    0.0.0.0 insightjs.com
    0.0.0.0 analytics.insightjs.com
    0.0.0.0 insightjs.org
  '';

  # Bluetooth : pilote, démarrage à l'allumage, et Blueman pour le panneau graphique.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
}
