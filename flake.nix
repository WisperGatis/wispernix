{
  description = "wisp nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    obscura-vpn.url = "path:./obscura-vpn";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    
    # The bad bad browser
    opera-flake = {
      url = "github:yisuidenghua/opera-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # The shell i'm not even sure i wanna use.
    #caelestia-shell = {
    # url = "github:caelestia-dots/shell";
    # inputs.nixpkgs.follows = "nixpkgs";
    #};

    herdr-nix = {
      url = "github:herdrdev/herdr-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ai-usagebar
    ai-usagebar = {
      url = "github:akitaonrails/ai-usagebar";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # noctalia-greeter
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Amane
    amane = {
      url = "github:MystiaFin/amane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # occt
    OCCT = {
      url = "github:Daaboulex/OCCT-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    #linux-wallpaper-engine = {
    # url = "github:jagrat7/linux-wallpaper-engine";
    #};
    
    simple-wallpaper-engine = {
     url = "github:Maxnights/simple-linux-wallpaperengine-gui";
     inputs = {
       nixpkgs.follows = "nixpkgs";
       #home-manager.follows = "home-manager";
     };
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

    #nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        nixpkgs-unstable = inputs.nixpkgs-unstable;
        zen-browser = inputs.zen-browser;
      };

      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        ./flake/modules.nix
      ];
    };
  };
}
