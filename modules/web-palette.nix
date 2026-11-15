# Recolors websites in Helium to follow the Matugen / Noctalia palette.
# - browser-extension/: the MV3 extension, loaded with --load-extension.
# - serve-palette.py: user service exposing ~/.config/web-palette/palette.json
#   on 127.0.0.1:8765 (the extension polls it).
# The palette file itself is written by Matugen (config/matugen/templates/web-palette.json).
{ config, pkgs, lib, ... }:
let
  extension = pkgs.callPackage ../browser-extension { };
  server = pkgs.writeShellApplication {
    name = "web-palette-server";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      exec python3 -I ${../browser-extension/serve-palette.py}
    '';
  };
in
{
  programs.helium.flags = [ "--load-extension=${extension}" ];

  systemd.user.services.web-palette-server = {
    description = "Serve the web-palette colors to the browser extension";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${server}/bin/web-palette-server";
      Restart = "on-failure";
    };
  };
}
