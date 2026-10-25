{ config, pkgs, lib, inputs, ... }:
let
  palette-video = pkgs.runCommand "palette-video" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    install -Dm755 ${./scripts/palette-video.fish} $out/bin/palette-video
    substituteInPlace $out/bin/palette-video \
      --replace-fail "#!/usr/bin/env fish" "#!${pkgs.fish}/bin/fish"
    wrapProgram $out/bin/palette-video \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ffmpeg pkgs.dipc ]}
    '';

in
{
  home.packages = with pkgs; [
    nwg-look
    adw-gtk3
    qt6Packages.qt6ct
    libsForQt5.qt5ct
    palette-video
    #dash-to-dock
    #inputs.linux-wallpaper-engine.packages.${pkgs.stdenv.hostPlatform.system}.default

    (python3.withPackages (ps: with ps; [
      pillow
    ]))
  ];
}
