{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  specialisation.cachyos.configuration = {
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
  
  security.polkit.enable = true;

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
  };
};

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "ch";
    variant = "fr";
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  programs.niri.enable = true;
  programs.hyprland.enable = true;
  programs.mango.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.sessionPackages = [ pkgs.unstable.mango ];
  
  # Ajouter COSMIC.
  services.desktopManager.cosmic = {
    enable = true;
    xwayland.enable = true;
  };
  
  programs.ssh.askPassword = lib.mkForce
  "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  

    fonts = {
    fontDir.enable = true;

    packages =
      [
        pkgs.noto-fonts
        pkgs.noto-fonts-cjk-sans
        pkgs.noto-fonts-color-emoji
      ]
      ++ builtins.filter lib.attrsets.isDerivation
        (builtins.attrValues pkgs.nerd-fonts);
  };

  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    
    
    config.niri = {
      default = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };

   # Millennium to make Steam better and allowing theming.
   programs.steam = {
      enable = true;
      package = pkgs.millennium-steam.override {
      extraArgs = "-system-composer -cef-disable-gpu-compositing";
      };
   };
  
  programs.firefox.enable = true;
  
  programs.npm.enable = true;

  console.keyMap = "fr_CH";

  services.printing.enable = true;
  
    programs.thunar = {
    enable = true;

    plugins = with pkgs.xfce; [
      pkgs.thunar-archive-plugin
      pkgs.thunar-volman
    ];
  };

  # Nécessaire hors session XFCE complète pour conserver les préférences Thunar.
  programs.xfconf.enable = true;

  # Corbeille, montages USB, réseaux et emplacements distants.
  services.gvfs.enable = true;

  # Miniatures dans Thunar.
  services.tumbler.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
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
  
  programs.fish.enable = true;
  
  virtualisation.docker.enable = true;

  # AMD overclocking.
  hardware.amdgpu.overdrive.enable = true;
  services.lact = {
      enable = true;
  };

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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-40.10.5"
  ];
  
  environment.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt6ct";
  };

  environment.systemPackages = with pkgs; [
      
    # Dubious steam needs
    xwayland-satellite
    
     # Dubious packages somehow needed.
     unstable.unrar
    
    # Gaming packages.
    wine
    wine-staging
    wine-wayland
    winetricks
    protontricks
    gamemode
    
    # Wallslop
    pkgs.mpvpaper
    matugen
    glow
    awww
    
    # gnome-slope
    gnome-tweaks
    nautilus
    gnome-console
    gnome-calculator
    gnome-calendar
    gnome-clocks
    gnome-system-monitor
    
    # hardware control
    lact
          
    vim
    fish
    wget
    # neovim
    fresh-editor
    fastfetch
    unstable.fetch
    hyfetch
    btop
    dipc
    tmux
    cava
    yazi
    linux-wallpaperengine
    unstable.cmatrix
    unstable.zellij
    unstable.herdr
    

    # Niri, mango and Hyprland slop
    niri
    polkit_gnome
    #unstable.mango
    hyprland
    unstable.noctalia
    unstable.caelestia-cli
    weathr
    unstable.concord-tui
    winboat

    # Terminals
    kitty
    ghostty
    alacritty
    rio
    foot
    ratty
    

    vesktop
    telegram-desktop
    unstable.whatsapp-electron
    
    # Burokrasy
    libreoffice

    # game slop
    # steam
    unstable.heroic
    lutris
    protonplus
    protonup-qt
    prismlauncher
    unstable.gamescope

    # Bigger dev slop
    t3code
    unstable.zed-editor
    vscode
    code-cursor
    mailspring
    unstable.opencode
    jetbrains-toolbox
    unstable.claude-code
    unstable.codex
    waydroid

    #dev slop
    #nodejs_26
    rustc
    python3
    rustup
    git
    cmake
    dotnet-sdk
    ninja
    gcc
    docker
    lazygit
    fzf
    uv
    github-desktop
    gitbutler
    pkg-config
    

    mullvad-vpn
    mullvad
    proton-vpn
    softether

    qbittorrent

    brave
    vivaldi
    google-chrome
    unstable.brave-origin
    unstable.librewolf
    unstable.tor-browser
    # pkgs.opera
    floorp-bin
    # inputs.waterfox.packages.${pkgs.system}.default
    # Currently broken due to missing deps from Mozilla, not obtainable due to Nix sandboxing blocking it.
    
    thunar
    
    # libvirt, qemu and kvm
    virt-viewer
    spice
    spice-gtk
    virtio-win
    win-spice
  ];
  
  home-manager = {
  useGlobalPkgs = true;
  useUserPackages = true;
  
  extraSpecialArgs = {
      inherit inputs;
  };

    users.wisp = import ./home.nix;
  };

 system.stateVersion = "26.05";
}
