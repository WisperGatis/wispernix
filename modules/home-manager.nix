{ config, pkgs, lib, inputs, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  
    extraSpecialArgs = {
      inherit inputs;
    };

    users.wisp = import ../home;
  };
}
