# Extra system modules that used to be written inline in flake.nix.
{ config, pkgs, lib, inputs, zen-browser, ... }:
{
  imports = [
    inputs.obscura-vpn.nixosModules.default
    inputs.helium-browser.nixosModules.default
    inputs.mangowm.nixosModules.mango

    # Stable chaotic.
    inputs.chaotic.nixosModules.nyx-cache
    inputs.chaotic.nixosModules.nyx-overlay
    inputs.chaotic.nixosModules.nyx-registry

    # For unstable chatoc branch.
    #inputs.chaotic.nixosModules.default

    inputs.codex-desktop-linux.nixosModules.default
    inputs.claude-desktop.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];

  services.obscura.enable = true;

  #inputs.OCCT.overlays.default
  #environment.systemPackages = [ claude-code ];

  programs.claude-desktop.enable = true;

  programs.codexDesktopLinux = {
    enable = true;
    # computerUseUi.enable = true;
    #remoteMobileControl.enable = true;
    #remoteControl.enable = true;
  };

  # If it works dude.
  #programs.dms-shell = {
  # enable = true;
  # package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # systemd.enable = false;

  # enableSystemMonitoring = true;
  # enableDynamicTheming = true;
  #};

  nixpkgs.overlays = [
    inputs.claude-code.overlays.default
    # Very stupid if it works.
    inputs.OCCT.overlays.default

    inputs.millennium.overlays.default
    inputs.helium-browser.overlays.default
    #nix-cachyos-kernel.overlays.pinned
    inputs.opera-flake.overlays.default
    (final: prev: {
      # test_afalg needs AF_ALG kernel support, which the builder sandbox lacks.
      openssl_1_1 = prev.openssl_1_1.overrideAttrs (_: { doCheck = false; });
      unstable = import inputs.nixpkgs-unstable {
        inherit (prev.stdenv.hostPlatform) system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-40.10.5"
          ];
        };
      };
    })
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    substituters = [
      "https://cache.nixos.org"
      #"https://attic.xuyh0120.win/lantian"
      # Same as bellow, secondary cache for nix-cachyos-kernel which sould not be here, since the main one mostly misses we have to use it sadly.
      #"https://cache.xinux.uz"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      #"lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      # Seconday cache should not be main nor be even present to begin with.
      #"cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0=" # xinux
    ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.steam.enable = true;

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ko_KR.UTF-8/UTF-8"
  ];

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nanum
      nanum-gothic-coding
    ];

    fontconfig.defaultFonts = {
      sansSerif = [
        "Noto Sans CJK KR"
        "NanumGothic"
      ];

      serif = [
        "Noto Serif CJK KR"
        "NanumMyeongjo"
      ];

      monospace = [
        "Noto Sans Mono CJK KR"
        "NanumGothicCoding"
      ];
    };
  };

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.helium = {
    enable = true;
    flags = [ "--ozone-platform-hint=auto" ];
  };

  environment.systemPackages = [
    inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.rhun-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
