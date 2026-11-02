{ config, pkgs, lib, inputs, ... }:

let
  # Les deux thèmes sont empaquetés séparément. Pour changer de curseur,
  # modifier uniquement activeCursorTheme ci-dessous.
  mkCursorTheme = name: pkgs.stdenvNoCC.mkDerivation {
    pname = "${name}-cursor-theme";
    version = "1.0";
    src = ../config/cursors/${name};
    dontBuild = true;

    installPhase = ''
      mkdir -p "$out/share/icons/${name}"
      cp -r "$src"/. "$out/share/icons/${name}/"
    '';
  };

  cursorThemes = {
    Aemeath = mkCursorTheme "Aemeath";
    Kama = mkCursorTheme "Kama";
    Alice_Kuonji = mkCursorTheme "Alice_Kuonji";
    Saber = mkCursorTheme "Saber";
    Chisa = mkCursorTheme "Chisa";
    Aemeath_sunglasses = mkCursorTheme "Aemeath_sunglasses";
    remielle_black = mkCursorTheme "remielle_black";
    remielle_white = mkCursorTheme "remielle_white";
    Arlecchino = mkCursorTheme "Arlecchino";
    ellen = mkCursorTheme "ellen";
    Rio = mkCursorTheme "Rio";
    Cinderella = mkCursorTheme "Cinderella";
  };

  activeCursorTheme = "Aemeath";
  activeCursorPackage = builtins.getAttr activeCursorTheme cursorThemes;

in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.spicetify
    inputs.simple-wallpaper-engine.homeManagerModules.default

    ./packages.nix
    ./shell.nix
    ./terminals.nix
    ./multiplexers.nix
    ./editors.nix
    ./apps.nix
    ./desktop.nix
    ./hyprland.nix
    ./waybar.nix
  ];

  home.username = "wisp";
  home.homeDirectory = "/home/wisp";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  programs.simple-wallpaper-engine.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
    "$HOME/.local/share/pnpm"
    "$HOME/.bun/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";

    # Disponible aux applis XWayland et aux applis qui lisent XCursor.
    XCURSOR_THEME = activeCursorTheme;
    XCURSOR_SIZE = "24";
  };

  # Pas de gestion GTK ici : Noctalia / Matugen s'en charge.
  home.pointerCursor = {
    enable = true;
    package = activeCursorPackage;
    name = activeCursorTheme;
    size = 24;

    gtk.enable = false;
    x11.enable = true;
  };
  
  gtk.iconTheme = {
    name = "Dracula";
    package = pkgs.dracula-icon-theme;  
  };

  #programs.simple-wallpaper-engine.enable = true;
}
