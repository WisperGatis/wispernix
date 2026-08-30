{ config, pkgs, inputs, ... }:

let
  aemeathCursor = pkgs.stdenvNoCC.mkDerivation {
    pname = "aemeath-cursor";
    version = "1.0";

    src = ./config/cursors/Aemeath;

    installPhase = ''
      mkdir -p "$out/share/icons"
      cp -r "$src" "$out/share/icons/Aemeath/"
    '';
  };

  spicePkgs =
    inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.spicetify
  ];

  home.username = "wisp";
  home.homeDirectory = "/home/wisp";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
    "$HOME/.local/share/pnpm"
    "$HOME/.bun/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";

    # Disponible aux applis XWayland et aux applis qui lisent XCursor.
    XCURSOR_THEME = "Aemeath";
    XCURSOR_SIZE = "24";
  };

  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];

    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };

  home.file.".local/bin/polkit-gnome-agent" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh
      exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
    '';
  };

  # Pas de gestion GTK ici : Noctalia / Matugen s'en charge.
  home.pointerCursor = {
    enable = true;
    package = aemeathCursor;
    name = "Aemeath";
    size = 24;

    gtk.enable = false;
    x11.enable = true;
  };
  
  gtk.iconTheme = {
    name = "Dracula";
    package = pkgs.dracula-icon-theme;  
  };

  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };

    settings = {
      shell = "fish";

      background = "#1e1e2e";
      foreground = "#cdd6f4";
      selection_background = "#585b70";
      selection_foreground = "#cdd6f4";
      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";

      color0 = "#45475a";
      color1 = "#f38ba8";
      color2 = "#a6e3a1";
      color3 = "#f9e2af";
      color4 = "#89b4fa";
      color5 = "#f5c2e7";
      color6 = "#94e2d5";
      color7 = "#bac2de";
      color8 = "#585b70";
      color9 = "#f38ba8";
      color10 = "#a6e3a1";
      color11 = "#f9e2af";
      color12 = "#89b4fa";
      color13 = "#f5c2e7";
      color14 = "#94e2d5";
      color15 = "#a6adc8";

      confirm_os_window_close = 0;
      enable_audio_bell = "no";
      window_padding_width = 10;
      hide_window_decorations = "yes";

      tab_bar_style = "powerline";
      active_tab_background = "#cba6f7";
      active_tab_foreground = "#1e1e2e";
      inactive_tab_background = "#313244";
      inactive_tab_foreground = "#cdd6f4";
    };

    shellIntegration = {
      enableFishIntegration = true;
    };
  };
  
  
  # tmux configurations.
  programs.tmux = {
    enable = true;

    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour "mocha"
          set -g @catppuccin_window_status_style "rounded"
          set -g mouse on
        '';
      }
    ];

    extraConfig = ''
      # Conserve la barre Tmux en bas.
      set -g status-position bottom

      # Restaure les sessions sauvées par resurrect.
      set -g @continuum-restore "on"
    '';
  };
  
  # neovim config with the usual LV
  programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
  };
  
  xdg.configFile."nvim" = {
      source = ./config/nvim;
      recursive = true;
  };
  

  # Spicetify configurations.
  programs.spicetify = {
    enable = true;

    theme = spicePkgs.themes.comfy;
    colorScheme = "Comfy";

    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
    ];
  };
  
  # adding librewolf dubious setup
  programs.librewolf = {
      enable = true;
      settings = {
          "privacy.resistFingerprinting" = false;
      };
  };

  home.packages = with pkgs; [
    nwg-look
    adw-gtk3
    qt6Packages.qt6ct
  ];

  xdg.configFile = {
    "niri/config.kdl" = {
      source = ./config/niri/config.kdl;
      force = true;
    };

    "niri/monitors.kdl" = {
      source = ./config/niri/monitors.kdl;
      force = true;
    };

    "mango/config.conf" = {
      source = ./config/mango/config.conf;
      force = true;
    };
  };
}