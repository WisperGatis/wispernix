{ config, pkgs, lib, inputs, ... }:
{
  environment.systemPackages = with pkgs; [

    # -- Hardware, overclocking & GPU --------------------------------
    # Very fun OC software
    corectrl
    stress-ng
    #inputs.occt-nix.packages.${pkgs.system}.occt
    pkgs.occt
    lact
    vulkan-tools

    # -- Monitoring & system info ------------------------------------
    btop
    fastfetch
    unstable.fetch
    hyfetch

    # -- Terminal emulators ------------------------------------------
    kitty
    ghostty
    alacritty
    rio
    foot
    ratty

    # -- Shell & CLI tools -------------------------------------------
    fish
    unstable.oh-my-posh
    wget
    dipc
    tmux
    unstable.zellij
    unstable.starship
    glow
    fzf
    #herdr
    inputs.herdr-nix.packages.${system}.default
    lsd

    # -- Editors -----------------------------------------------------
    vim
    # neovim
    fresh-editor
    sublime4
    unstable.vscodium
    unstable.zed-editor
    vscode
    code-cursor
    jetbrains-toolbox
    vis
    unstable.emacs
    unstable.eclipses.eclipse-cpp

    # -- Git -----------------------------------------------------
    git
    github-cli
    github-desktop
    unstable.lazygit
    lazygit
    #gitbutler

    # -- Languages & toolchains --------------------------------------
    #nodejs_26
    rustc
    cargo
    clippy
    rustfmt
    rustup
    python3
    python3Packages.ply
    uv
    nodejs_latest
    yarn
    pnpm
    unstable.bun
    zig
    cmake
    gnumake
    ninja
    gcc
    gdb
    pkg-config
    bubblewrap

    # -- .NET --------------------------------------------------------
    #Dotnet while we are at it.
    unstable.dotnet-sdk_10
    unstable.dotnet-sdk_11
    dotnet-sdk
    dotnet-sdk_10
    roslyn
    unstable.roslyn-ls

    # -- AI tools ----------------------------------------------------
    unstable.opencode
    unstable.opencode-desktop
    pkgs.claude-code
    #unstable.claude-code
    unstable.codex
    unstable.antigravity-cli
    unstable.antigravity-ide
    unstable.crush
    unstable.t3code
    inputs.ai-usagebar.packages.${pkgs.stdenv.hostPlatform.system}.default

    # -- Compositors & window managers -------------------------------
    #Niri, mango and Hyprland slop
    sway
    niri
    hyprland
    unstable.dwm
    unstable.labwc
    unstable.noctalia
    unstable.umbriel
    unstable.noctalia-greeter
    #unstable.mango
    #unstable.caelestia-cli
    #inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
    polkit_gnome
    xrandr
    dmenu
    st
    feh
    xclip
    picom

    # -- Wayland & screen tools --------------------------------------
    # Dubious steam needs
    xwayland-satellite
    wayland-utils
    wf-recorder
    wl-screenrec

    # -- Audio, video & media ----------------------------------------
    pipewire
    ffmpeg
    pavucontrol
    cava
    feishin
    unstable.spotifast
    unstable.zapfast

    # -- Theming & wallpapers ----------------------------------------
    # Wallslop
    pkgs.mpvpaper
    matugen
    awww
    unstable.linux-wallpaperengine
    #inputs.linux-wallpaper-engine.packages.${pkgs.stdenv.hostPlatform.system}.default

    # -- Fonts -------------------------------------------------------
    # Stoopid font that doesn't wanna install itself properly through font packages.
    google-fonts

    # -- GNOME apps --------------------------------------------------
    # gnome-slope
    gnome-tweaks
    nautilus
    gnome-console
    gnome-calculator
    gnome-calendar
    gnome-clocks
    gnome-system-monitor
    gnome-extension-manager
    gnome-disk-utility

    # Budgie apps and slope.
    loupe
    file-roller
    evince
    dconf-editor


    # -- Files -------------------------------------------------------
    thunar
    yazi
    unstable.superfile

    # -- Browsers ----------------------------------------------------
    pkgs.firefox_nightly
    brave
    vivaldi
    google-chrome
    unstable.brave-origin
    unstable.librewolf
    unstable.tor-browser
    floorp-bin
    mullvad-browser
    #pkgs.opera
    #inputs.waterfox.packages.${pkgs.system}.default
    #Currently broken due to missing deps from Mozilla, not obtainable due to Nix sandboxing blocking it.

    # -- Communication -----------------------------------------------
    vesktop
    telegram-desktop
    unstable.whatsapp-electron
    mailspring
    unstable.concord-tui
    unstable.karere

    # -- Notes & office ----------------------------------------------
    # Toyota.
    obsidian
    unstable.siyuan
    # Burokrasy
    libreoffice
    onlyoffice-desktopeditors

    # -- Gaming ------------------------------------------------------
    # Gaming packages.
    wine
    wine-staging
    wine-wayland
    winetricks
    protontricks
    gamemode
    pkgs.gamescope_git
    # game slop
    #steam
    unstable.heroic
    lutris
    protonplus
    protonup-qt
    prismlauncher
    unstable.lunar-client
    unstable.gamescope
    unstable.mangohud
    unstable.goverlay

    # -- Containers & virtualization ---------------------------------
    docker
    waydroid
    winboat
    quickemu
    # libvirt, qemu and kvm
    virt-viewer
    spice
    spice-gtk
    virtio-win
    win-spice

    # -- Networking & VPN --------------------------------------------
    mullvad-vpn
    mullvad
    proton-vpn
    softether

    # -- Downloads, archives & filesystems ---------------------------
    qbittorrent
    # Dubious packages somehow needed.
    unstable.unrar
    ntfs3g

    # -- Fun & misc --------------------------------------------------
    unstable.cmatrix
    weathr
    inputs.amane.packages.x86_64-linux.default
  ];
}
