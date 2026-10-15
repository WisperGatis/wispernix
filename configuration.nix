{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.noctalia-greeter.nixosModules.default
  ];

  # Kernels
  specialisation.cachyos.configuration = {
    boot.kernelPackages = 
      pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;
  };
  
  # To uncomment and comment the above block to enable Zen kernel
  #boot.kernelPackages = pkgs.linuxPackages_zen;

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

  # storage optimizations cuz holy shit
  nix.settings.auto-optimise-store = true;
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "ch";
    variant = "fr";
  };

  # greetd + Noctalia greeter à la place de SDDM.
  # Le module active greetd, Polkit et AccountsService tout seul
  # et lance noctalia-greeter-session.
  services.displayManager.noctalia-greeter = {
    enable = true;

    settings = {
      # Curseur custom Aemeath, stocké dans /etc/nixos/config/cursors/Aemeath
      # (le dossier contient index.theme et cursors/).
      cursor = {
        theme = "Aemeath";
        size = 24;
        path = pkgs.runCommand "aemeath-cursor" { } ''
          mkdir -p $out/share/icons
          cp -r ${./config/cursors/Aemeath} $out/share/icons/Aemeath
        '';
      };
    };
  };

  # Plasma, GNOME et COSMIC activent leur propre display manager par défaut
  # (SDDM, GDM, cosmic-greeter) : on les coupe pour laisser greetd seul.
  services.displayManager.sddm.enable = lib.mkForce false;
  services.displayManager.gdm.enable = lib.mkForce false;
  services.displayManager.cosmic-greeter.enable = lib.mkForce false;

  services.desktopManager.plasma6.enable = true;

  programs.niri.enable = true;
  programs.hyprland.enable = true;
  programs.mango.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.sessionPackages = [
    pkgs.unstable.mango

    # Umbriel session entry (uses its start-umbriel launcher).
    ((pkgs.runCommand "umbriel-session"
      { passthru.providedSessions = [ "umbriel" ]; }
      ''
        mkdir -p $out/share/wayland-sessions
        cat > $out/share/wayland-sessions/umbriel.desktop <<EOF
        [Desktop Entry]
        Name=Umbriel
        Comment=Umbriel Wayland compositor
        Exec=${pkgs.unstable.umbriel}/bin/start-umbriel
        Type=Application
        DesktopNames=Umbriel
        EOF
      ''))
  ];
  # Ajouter COSMIC.
  services.desktopManager.cosmic = {
    enable = true;
    xwayland.enable = true;
  };

  # GPU screen recorder?
  programs.gpu-screen-recorder = {
    enable = true;
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
  
  # xdg portal, Discord/vesktop/legcord streaming &&. Screen recorder for most Wayland setups
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-wlr
    ];

    config.umbriel = {
      efault = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
    
    
    config.niri = {
      default = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };

  # Any discord client streaming output selection 
  xdg.portal.wlr.settings = {
    screencast = {
      chooser_type = "simple";
      chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
    };
  };

  #Millennium to make Steam better and allowing theming.
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

  #Nécessaire hors session XFCE complète pour conserver les préférences Thunar.
  programs.xfconf.enable = true;

  #Corbeille, montages USB, réseaux et emplacements distants.
  services.gvfs.enable = true;

  #Miniatures dans Thunar.
  services.tumbler.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
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
    "ladybird-0-unstable-2026-06-05"
    "openssl-1.1.1w"
  ];
  
  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };

  programs.nix-ld = {
    enable = true;
  };

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  programs.appimage.package = pkgs.appimage-run.override
  {
    extraPkgs = pkgs: 
    [
      pkgs.icu
      pkgs.libxcrypt-legacy
      pkgs.python312
      pkgs.python312Packages.torch
    ];
  };

  environment.systemPackages = with pkgs; [
      
    # Stoopid font that doesn't wanna install itself properly through font packages.
    google-fonts
      
    # Dubious steam needs
    xwayland-satellite
    wayland-utils
    pavucontrol
    wf-recorder
    wl-screenrec
    pipewire
    ffmpeg
    
    # Dubious packages somehow needed.
    unstable.unrar
    ntfs3g
    vulkan-tools
    
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
    
    #hardware control
    lact
          
    vim
    github-cli
    gdb
    unstable.vscodium
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
    unstable.lazygit
    cava
    yazi
    linux-wallpaperengine
    unstable.cmatrix
    unstable.zellij
    #herdr
    inputs.herdr-nix.packages.${system}.default
    sublime4
    yarn
    pnpm
    unstable.bun
    
    #Dotnet while we are at it.
    unstable.dotnet-sdk_10
    unstable.dotnet-sdk_11
    roslyn
    unstable.roslyn-ls

    #Niri, mango and Hyprland slop
    niri
    polkit_gnome
    #unstable.mango
    hyprland
    unstable.noctalia
    #unstable.caelestia-cli
    unstable.umbriel
    unstable.noctalia-greeter
    weathr
    unstable.concord-tui
    winboat
    quickemu
    unstable.karere

    #Terminals
    kitty
    ghostty
    alacritty
    rio
    foot
    ratty

    vesktop
    unstable.spotifast
    unstable.zapfast
    telegram-desktop
    unstable.whatsapp-electron
    
    #Burokrasy
    libreoffice
    onlyoffice-desktopeditors

    #game slop
    #steam
    unstable.heroic
    lutris
    protonplus
    protonup-qt
    prismlauncher
    unstable.lunar-client
    unstable.gamescope

    #Bigger dev slop
    unstable.t3code
    unstable.zed-editor
    vscode
    code-cursor
    mailspring
    unstable.opencode
    unstable.opencode-desktop
    jetbrains-toolbox
    #unstable.claude-code
    pkgs.claude-code
    unstable.codex
    unstable.antigravity-cli
    unstable.antigravity-ide
    unstable.crush
    waydroid

    #dev slop
    #nodejs_26
    rustc
    nodejs_latest
    cargo
    clippy
    rustfmt
    python3
    rustup
    git
    cmake
    dotnet-sdk
    dotnet-sdk_10
    ninja
    gcc
    bubblewrap
    docker
    lazygit
    fzf
    vis
    uv
    github-desktop
    #gitbutler
    pkg-config
    zig
    python3Packages.ply
    inputs.amane.packages.x86_64-linux.default  

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
    #pkgs.opera
    floorp-bin
    #inputs.waterfox.packages.${pkgs.system}.default
    #Currently broken due to missing deps from Mozilla, not obtainable due to Nix sandboxing blocking it.
    
    thunar

    #inputs from the flakes.
    inputs.ai-usagebar.packages.${pkgs.stdenv.hostPlatform.system}.default
    #inputs.linux-wallpaper-engine.packages.${pkgs.stdenv.hostPlatform.system}.default
    
    #libvirt, qemu and kvm
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
