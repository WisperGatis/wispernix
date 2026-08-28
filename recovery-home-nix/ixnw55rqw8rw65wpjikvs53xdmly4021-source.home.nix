{ config, pkgs, inputs, ... }:

let
  arlecchinoCursor = pkgs.stdenvNoCC.mkDerivation {
    pname = "arlecchino-cursor";
    version = "1.0";

    src = ./config/cursors/Aemeath;

    installPhase = ''
      mkdir -p "$out/share/icons"
      cp -r "$src" "$out/share/icons/Aemeath"
    '';
  };

  spicePkgs =
    inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
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

  # Thème Catppuccin avec la variante Mocha.
  theme = spicePkgs.themes.catppuccin;
  colorScheme = "mocha";

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
  ];

  # Catppuccin global — Kvantum utilisera ces valeurs par défaut.
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";

    # Thème Qt utilisé par Dolphin, Kate, QtCreator, etc.
    kvantum = {
      enable = true;
      apply = true;
    };
  };

  # Force les applications Qt5 et Qt6 lancées dans Niri
  # à utiliser le moteur de thème Kvantum.
  qt = {
    enable = true;
    style.name = "kvantum";
  };

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