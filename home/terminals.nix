{ config, pkgs, lib, inputs, ... }:
{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };

    settings = {
      shell = "fish";

      confirm_os_window_close = 0;
      enable_audio_bell = "no";
      window_padding_width = 10;
      hide_window_decorations = "yes";

      tab_bar_style = "powerline";
    };

    # Charge le thème généré dynamiquement par Noctalia.
    # Ce chemin est relatif à ~/.config/kitty/.
    extraConfig = ''
      include themes/noctalia.conf
    '';

    shellIntegration = {
      enableFishIntegration = true;
    };
  };

  programs.alacritty = {
    enable = true;
    
    settings = {
      general.import = ["~/.config/alacritty/themes/noctalia.toml"];

      font = {
        normal.family = "JetBrainsMono Nerd Font";
        #size 12;
      };

      window.opacity = 0.90;
    };
  };

  programs.foot = {
    enable = true;

    settings = {
      main = {
        font = "JetBrainsMono Nerd Font";
        include = "~/.config/foot/themes/noctalia";
      };

      colors-dark.alpha = "0.90";
      colors-light.alpha = "0.90";
    };
  };

  # WezTerm : configuration dans config/wezterm/wezterm.lua.
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ../config/wezterm/wezterm.lua;
    enableFishIntegration = true;
  };

  # Noctalia rend config/wezterm/colors/noctalia.lua (modèle) vers
  # ~/.config/wezterm/colors/noctalia.lua, même schéma que helix (home/editors.nix).
  xdg.configFile = {
    "noctalia/templates/wezterm-colors.lua".source = ../config/wezterm/colors/noctalia.lua;

    "noctalia/wezterm.toml".text = ''
      [theme.templates.user.wezterm]
      input_path = "templates/wezterm-colors.lua"
      output_path = "$XDG_CONFIG_HOME/wezterm/colors/noctalia.lua"
    '';
  };
}
