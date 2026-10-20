{ config, pkgs, lib, inputs, ... }:
{
  fonts = {
    fontDir.enable = true;

    packages =
    [
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-color-emoji
    ]
    ++ builtins.filter lib.attrsets.isDerivation
    (builtins.attrValues pkgs.nerd-fonts);
  };
}
