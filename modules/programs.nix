{ config, pkgs, lib, inputs, ... }:
{
  programs.firefox.enable = true;

  programs.npm.enable = true;

  programs.fish.enable = true;

  programs.nix-ld = {
    enable = true;
  };

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  programs.appimage.package = pkgs.appimage-run.override
  {
    extraPkgs = pkgs: 
    [
      pkgs.icu
      pkgs.libxcrypt-legacy
      pkgs.python312
      pkgs.python312Packages.torch
    ];
  };
}
