{
  description = "wisp nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # The bad bad browser
    opera-flake = {
      url = "github:yisuidenghua/opera-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Adding mangowm as a flake rather than from nixpkgs
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
     url = "github:nix-community/home-manager?ref=release-26.05";
     inputs.nixpkgs.follows = "nixpkgs";
   };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    
    quickemu.url = "https://flakehub.com/f/quickemu-project/quickemu/4.9.9";

    helium-browser = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    waterfox = {
      url = "github:sammypanda/nixos-waterfox";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Codex slop.
    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Claude slop.
    claude-desktop = {
      url = "github:nmcbride/claude-desktop-nix";
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
      opera-flake,
      waterfox,
      mangowm,
      quickemu,
      codex-desktop-linux,
      claude-desktop,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs nixpkgs-unstable zen-browser;
        };

	# Modules . . .
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix
          helium-browser.nixosModules.default
          mangowm.nixosModules.mango

	  codex-desktop-linux.nixosModules.default

	  claude-desktop.nixosModules.default

	  {
	     programs.claude-desktop.enable = true;
	  }

	  {
	      programs.codexDesktopLinux = {
		enable = true;
		computerUseUi.enable = true;
		remoteMobileControl.enable = true;
		remoteControl.enable = true;
	      };
	  }

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
                opera-flake.overlays.default
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
