{ config, pkgs, lib, inputs, ... }:
let
  spicePkgs =
    inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};

in
{
  # Spicetify configurations.
  programs.spicetify = {
    enable = true;

    theme = spicePkgs.themes.comfy;
    colorScheme = "Comfy";

    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
    ];
  };

  # adding librewolf dubious setup
  programs.librewolf = {
    enable = true;
    settings = {
      "privacy.resistFingerprinting" = false;
    };
  };
}
