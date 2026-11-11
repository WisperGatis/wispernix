{ config, pkgs, lib, inputs, ... }:
{
  services.flatpak.enable = true;

  services.printing.enable = true;

  # Les clés autorisées sont gérées localement, sans secret dans le dépôt.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
