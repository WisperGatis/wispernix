{ config, pkgs, inputs, ... }:

let
  arlecchinoCursor = pkgs.stdenvNoCC.mkDerivation {
    pname = "arlecchino-cursor";
    version = "1.0";

    src = ./config/cursors/Arlecchino;

    installPhase = ''
      mkdir -p "$out/share/icons"
      cp -r "$src" "$out/share/icons/Arlecchino"
    '';
  };

  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.spicetify
  ];

  home.username = "wisp";
  home.homeDirectory = "/home/wisp";

  # À choisir maintenant, puis ne plus modifier.
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # Agent Polkit lancé explicitement par Niri/Mango.
  home.file.".local/bin/polkit-gnome-agent" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh
      exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
    '';
  };

  # Curseur XCursor personnalisé.
  home.pointerCursor = {
    enable = true;

    package = arlecchinoCursor;
    name = "Arlecchino";
    size = 24;

    gtk.enable = true;
    x11.enable = true;
  };

  programs.spicetify = {
    enable = true;

    # Thème catppuccin
    spicePkgs.themes.catppuccin-mocha;

    # Extensions natives déclaratives.
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
    ];
  };

  home.packages = with pkgs; [
    # Utilitaires de thème GTK.
    adw-gtk3
    nwg-look

    # Intégration Qt.
    qt6Packages.qt6ct
  ];

  xdg.configFile = {
    "niri/config.kdl" = {
      source = ./config/niri/config.kdl;
      force = true;
    };

    "niri/monitors.kdl" = {
      source = ./config/niri/monitors.kdl;
      force = true;
    };

    "mango/config.conf" = {
      source = ./config/mango/config.conf;
      force = true;
    };
  };
}