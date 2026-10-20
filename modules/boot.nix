{ config, pkgs, lib, inputs, ... }:
{
  # Kernels
  # The spec ones are from Lantian which is down due to security concern so we fetch it from chaotic.
  specialisation.cachyos.configuration = {
    #boot.kernelPackages =  
     boot.kernelPackages = pkgs.linuxPackages_cachyos-bore;
  };

  #boot.kernelPackages = pkgs.linuxPackages_cachyos-bore;

  # To uncomment and comment the above block to enable Zen kernel
  #boot.kernelPackages = pkgs.linuxPackages_zen;
  # Adding a lts just in case.
  # boot.kernelPackages = pkgs.linuxPackages_6_6;

  # Mesa git integration.
  #chaotic.mesa-git.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
}
