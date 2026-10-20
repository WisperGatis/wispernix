{ config, pkgs, lib, inputs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # AMD overclocking.
  hardware.amdgpu.overdrive.enable = true;
  environment.sessionVariables.RUSTICL_ENABLE = "radeonsi";
  services.lact = {
    enable = true;
  };

  hardware.graphics.extraPackages = [ pkgs.mesa.opencl ];

}
