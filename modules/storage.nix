{ config, pkgs, lib, inputs, ... }:
{
  # Mounting of other drives.
  # Arch drive .
  fileSystems."/run/media/wisp/a633daec-523b-4395-88b0-4982fecf0df9" = {
    device = "/dev/disk/by-uuid/a633daec-523b-4395-88b0-4982fecf0df9";
    fsType = "btrfs";
    options = [
      "subvolid=5"
      "rw"
      "noatime"
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };

  # 2nd btrfs drive (samsung T7 basically)
  fileSystems."/run/media/wisp/4947f1a1-c254-44b2-a57f-10fefa1d5dce" = {
    device = "/dev/disk/by-uuid/4947f1a1-c254-44b2-a57f-10fefa1d5dce";
    fsType = "btrfs";
    options = [
      "rw"
      "noatime"
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };
  
  # He was mike
  fileSystems."/run/media/wisp/He was Mike" = {
    device = "/dev/disk/by-uuid/74DCF071DCF02ECC";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=1000"
      "umask=022"
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };
  
  # He tried to be Mike but failed.
  fileSystems."/run/media/wisp/He tried to be mike but failed" = {
    device = "/dev/disk/by-uuid/389288F69288BA40";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=1000"
      "umask=022"
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };

  # the oddly small one with 223 gigs 
  fileSystems."/run/media/wisp/5422750A2274F1FA" = {
    device = "/dev/disk/by-uuid/5422750A2274F1FA";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=1000"
      "umask=022"
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };
  
  # the oddly much bigger one 1tb
  fileSystems."/run/media/wisp/F6A07EF4A07EBAA7" = {
    device = "/dev/disk/by-uuid/F6A07EF4A07EBAA7";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=1000"
      "umask=022"
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };
}
