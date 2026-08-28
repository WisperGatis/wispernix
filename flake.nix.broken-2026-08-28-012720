{
  description = "wisp nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
     url = "github:nix-community/home-manager?ref=release-26.05";
     inputs.nixpkgs.follows = "nixpkgs";
   };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";

    helium-browser = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs =
    inputs@{
      self,
      home-manager,
      nixpkgs,
      nixpkgs-unstable,
      zen-browser,
      millennium,
      helium-browser,
      nix-cachyos-kernel,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs nixpkgs-unstable zen-browser;
        };
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix
          helium-browser.nixosModules.default
          home-manager.nixosModules.home-manager
          (
            {
              pkgs,
              zen-browser,
              ...
            }:
            {
              nixpkgs.overlays = [
                inputs.millennium.overlays.default
                helium-browser.overlays.default
                nix-cachyos-kernel.overlays.pinned
                (final: prev: {
                    unstable = import nixpkgs-unstable {
                        inherit (prev) system;
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
                  "https://attic.xuyh0120.win/lantian"
                ];
                trusted-public-keys = [
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                  "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
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
                zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
              ];
            }
          )
        ];
      };
    };
}