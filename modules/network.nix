{ config, pkgs, lib, inputs, ... }:
{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
}
