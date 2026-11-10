{ config, pkgs, lib, inputs, ... }:
{
  # Ryoku shell profile.
  #
  # A NixOS specialisation: the normal system is left untouched and an extra
  # "ryoku" entry shows up in the systemd-boot menu. Everything Ryoku related
  # (the module import included) lives inside the specialisation, so it can not
  # leak into the default profile.
  #
  # Ryoku brings its own Hyprland / niri / mango, its own SDDM theme and its own
  # pinned package set (do NOT make the `ryoku` input follow our nixpkgs, the
  # Ryoku port documents that this breaks its fixed-output derivations).
  specialisation.ryoku.configuration = {
    imports = [ inputs.ryoku.nixosModules.default ];

    programs.ryoku = {
      enable = true;
      defaultCompositor = "hyprland";
      browser = "chromium";
      shell = "fish";
      # Hub updates would try to bump an input in /etc/nixos; keep the default
      # unless this repo lives elsewhere.
      # updateFlake = "/etc/nixos";
    };

    # Ryoku uses SDDM with its own theme, so hand the login screen back to it.
    services.displayManager.noctalia-greeter.enable = lib.mkForce false;
    services.greetd.enable = lib.mkForce false;
    # The host forces sddm off with mkForce (priority 50), so beat it with 40.
    services.displayManager.sddm.enable = lib.mkOverride 40 true;
    services.displayManager.cosmic-greeter.enable = lib.mkOverride 40 false;

    # One shell at a time: keep DMS from fighting Ryoku for the bar, notifications
    # and the layer-shell surfaces.
    programs.dms-shell.enable = lib.mkForce false;
  };
}
