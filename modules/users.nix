{ config, pkgs, lib, inputs, ... }:
{
  # user(s)? 
  users.users.wisp = {
    isNormalUser = true;
    description = "wisp";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "libvirtd"
      "docker"
    ];

    packages = with pkgs; [
      kdePackages.kate
      thunderbird
    ];
  };
}
