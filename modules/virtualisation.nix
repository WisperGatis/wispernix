{ config, pkgs, lib, inputs, ... }:
{
  # QEMU / KVM / libvirt / Virt-Manager.
  virtualisation = {
    libvirtd = {
      enable = true;

      qemu = {
        package = pkgs.qemu_kvm;

        # TPM 2.0 émulé, requis par Windows 11.
        swtpm.enable = true;
      };
    };

    # Redirection d'USB dans les VMs via SPICE.
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  virtualisation.docker.enable = true;
}
