{ config, pkgs, lib, inputs, ... }:
{
  imports = [ inputs.noctalia-greeter.nixosModules.default ];

  # greetd + Noctalia greeter à la place de SDDM.
  # Le module active greetd, Polkit et AccountsService tout seul
  # et lance noctalia-greeter-session.
  services.displayManager.noctalia-greeter = {
    enable = true;

    settings = {
      # Curseur custom Aemeath, stocké dans /etc/nixos/config/cursors/Aemeath
      # (le dossier contient index.theme et cursors/).
      cursor = {
        theme = "Aemeath";
        size = 24;
        path = pkgs.runCommand "aemeath-cursor" { } ''
          mkdir -p $out/share/icons
          cp -r ${../config/cursors/Aemeath} $out/share/icons/Aemeath
        '';
      };
    };
  };

  # Plasma, GNOME et COSMIC activent leur propre display manager par défaut
  # (SDDM, GDM, cosmic-greeter) : on les coupe pour laisser greetd seul.
  services.displayManager.sddm.enable = lib.mkForce false;
  services.displayManager.gdm.enable = lib.mkForce false;
  services.displayManager.cosmic-greeter.enable = lib.mkForce false;
}
