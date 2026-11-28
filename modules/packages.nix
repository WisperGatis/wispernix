{ config, pkgs, lib, inputs, ... }:
{
  environment.systemPackages = with pkgs; [

    # -- Hardware, overclocking & GPU --------------------------------

    corectrl
    stress-ng
    #inputs.occt-nix.packages.${pkgs.stdenv.hostPlatform.system}.occt
    pkgs.occt
    lact
    vulkan-tools
    nh

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
    zsh
    unstable.oh-my-posh
    wget
    dipc
    tmux
    unstable.zellij
    unstable.starship
    glow
    fzf
    #herdr
    inputs.herdr-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    lsd
    htop

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
    nasm
    zip

    # -- .NET --------------------------------------------------------

    unstable.dotnet-sdk_10
    unstable.dotnet-sdk_11
    dotnet-sdk
    dotnet-sdk_10
    roslyn
    unstable.roslyn-ls

    # -- AI tools ----------------------------------------------------

    #unstable.opencode
    #unstable.opencode-desktop
    pkgs.claude-code
    #unstable.claude-code
    unstable.codex
    unstable.antigravity-cli
    unstable.antigravity-ide
    unstable.antigravity-hub
    unstable.crush
    unstable.t3code
    # Its test suite needs the gh CLI at build time, which the Nix sandbox lacks.
    (inputs.ai-usagebar.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (_: {
      doCheck = false;
    }))
    #unstable.herdr-desktop

    # -- Compositors & window managers -------------------------------

    sway
    niri
    unstable.hyprland
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

    pkgs.mpvpaper
    matugen
    awww
    unstable.linux-wallpaperengine
    #inputs.linux-wallpaper-engine.packages.${pkgs.stdenv.hostPlatform.system}.default

    # -- Fonts -------------------------------------------------------

    google-fonts

    # -- GNOME apps --------------------------------------------------

    gnome-tweaks
    nautilus
    gnome-console
    gnome-calculator
    gnome-calendar
    gnome-clocks
    gnome-system-monitor
    gnome-extension-manager
    gnome-disk-utility


    loupe
    file-roller
    evince
    dconf-editor


    # -- Files -------------------------------------------------------

    thunar
    yazi
    unstable.superfile

    # -- Browsers ----------------------------------------------------

    brave
    brave-origin
    vivaldi
    google-chrome
    unstable.librewolf
    unstable.tor-browser
    floorp-bin
    mullvad-browser
    #pkgs.opera
    #inputs.waterfox.packages.${pkgs.stdenv.hostPlatform.system}.default
    #Currently broken due to missing deps from Mozilla, not obtainable due to Nix sandboxing blocking it.

    # -- Communication -----------------------------------------------

    vesktop
    telegram-desktop
    unstable.whatsapp-electron
    mailspring
    #unstable.concord-tui
    unstable.karere

    # -- Notes & office ----------------------------------------------

    obsidian
    unstable.siyuan
    # Burokrasy
    libreoffice
    onlyoffice-desktopeditors

    # -- Gaming ------------------------------------------------------

    wine
    wine-staging
    wine-wayland
    winetricks
    protontricks
    gamemode
    gamescope
    #pkgs.gamescope_git
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
    # Needed for Ladybird and some other packages.
    unstable.unrar
    ntfs3g

    # -- Fun & misc --------------------------------------------------

    unstable.cmatrix
    weathr
    inputs.betterbird-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.amane.packages.x86_64-linux.default
  ];
}
