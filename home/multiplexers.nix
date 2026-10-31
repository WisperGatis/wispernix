{ config, pkgs, lib, inputs, ... }:
{
  # tmux configurations.
  programs.tmux = {
    enable = true;

    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
      #{
        #plugin = catppuccin;
        #extraConfig = ''
        #  set -ag terminal-overrides ",*:RGB"
        # set -g @catppuccin_flavour "mocha"
        #  set -g @catppuccin_window_status_style "rounded"
        #  set -g mouse on
        # '';
      #}
    ];
    
    extraConfig = ''
      # Conserve la barre Tmux en bas.
      set -g status-position bottom

      # Restaure les sessions sauvées par resurrect.
      set -g @continuum-restore "on"
        source-file -q ~/.config/tmux/themes/noctalia.conf

      # --- Souris + copie automatique à la sélection (Wayland) ---
      set -g mouse on
      set -g set-clipboard on
      bind -T copy-mode MouseDragEnd1Pane send -X copy-pipe-and-cancel "${pkgs.wl-clipboard}/bin/wl-copy"
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "${pkgs.wl-clipboard}/bin/wl-copy"

      # --- Couleurs 24 bits ---
      set -ag terminal-overrides ",*:RGB"

      # --- Barre de statut en capsules arrondies ---
      set -g status on
      set -g status-position bottom
      set -g status-interval 2
      set -g status-justify left
      set -g status-left-length 40
      set -g status-right-length 80

      # Nom de l'app qui tourne dans la fenêtre
      set -g @app '#{?#{||:#{m:*claude*,#{pane_current_command}},#{m:*Claude*,#{pane_title}}},Claude,#{?#{||:#{m:nvim,#{pane_current_command}},#{m:vim,#{pane_current_command}}},Neovim,#{?#{m:opencode,#{pane_current_command}},OpenCode,#{pane_current_command}}}}'

      set -g status-left "#[fg=#{@noctalia_primary},bg=#{@noctalia_surface_container_low},nobold]\ue0b6#[fg=#{@noctalia_on_primary},bg=#{@noctalia_primary},bold] \uf313 #S #[fg=#{@noctalia_primary},bg=#{@noctalia_surface_container_low},nobold]\ue0b4 "

      # Les styles sont portés par les formats, on neutralise ceux du thème
      set -g window-status-style "default"
      set -g window-status-last-style "default"
      set -g window-status-current-style "default"
      set -g window-status-separator " "
      set -g window-status-format "#[fg=#{@noctalia_surface_container_highest},bg=#{@noctalia_surface_container_low},nobold]\ue0b6#[fg=#{@noctalia_on_surface_variant},bg=#{@noctalia_surface_container_highest}] #I #{E:@app} #[fg=#{@noctalia_surface_container_highest},bg=#{@noctalia_surface_container_low},nobold]\ue0b4"
      set -g window-status-current-format "#[fg=#{@noctalia_primary},bg=#{@noctalia_surface_container_low},nobold]\ue0b6#[fg=#{@noctalia_on_primary},bg=#{@noctalia_primary},bold] #I #{E:@app} #[fg=#{@noctalia_primary},bg=#{@noctalia_surface_container_low},nobold]\ue0b4"
    '';
  };

  programs.zellij = {
    enable = true;
    enableFishIntegration = false;

    settings = {
      theme = "noctalia";

      # Options Zellij normales : reste géré par Home Manager
      #default_shell = "fish";
      pane_frames = false;
      mouse_mode = true;
      copy_on_select = true;
      scroll_buffer_size = 10000;
    };
  };

  # Reload tmux whenever Noctalia rewrites its theme, regardless of which
  # compositor is running (Umbriel's hooks used to do this).
  systemd.user.paths.tmux-theme-reload = {
    Unit.Description = "Watch the Noctalia tmux theme directory";
    Path.PathChanged = "%h/.config/tmux/themes";
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.tmux-theme-reload = {
    Unit.Description = "Reload the Noctalia theme in running tmux sessions";
    Service = {
      Type = "oneshot";
      # The leading "-" ignores the failure when no tmux server is running.
      ExecStart = "-${pkgs.tmux}/bin/tmux source-file -q %h/.config/tmux/themes/noctalia.conf";
    };
  };

  xdg.configFile = {
    "noctalia/templates/zellij-theme.kdl".text = ''
      themes {
        noctalia {
          text_unselected {
            base {{colors.on_surface.default.red}} {{colors.on_surface.default.green}} {{colors.on_surface.default.blue}}
            background {{colors.surface.default.red}} {{colors.surface.default.green}} {{colors.surface.default.blue}}
            emphasis_0 {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_1 {{colors.secondary.default.red}} {{colors.secondary.default.green}} {{colors.secondary.default.blue}}
            emphasis_2 {{colors.tertiary.default.red}} {{colors.tertiary.default.green}} {{colors.tertiary.default.blue}}
            emphasis_3 {{colors.on_surface_variant.default.red}} {{colors.on_surface_variant.default.green}} {{colors.on_surface_variant.default.blue}}
          }

          text_selected {
            base {{colors.on_primary.default.red}} {{colors.on_primary.default.green}} {{colors.on_primary.default.blue}}
            background {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_0 {{colors.on_primary.default.red}} {{colors.on_primary.default.green}} {{colors.on_primary.default.blue}}
            emphasis_1 {{colors.on_primary_container.default.red}} {{colors.on_primary_container.default.green}} {{colors.on_primary_container.default.blue}}
            emphasis_2 {{colors.on_surface.default.red}} {{colors.on_surface.default.green}} {{colors.on_surface.default.blue}}
            emphasis_3 {{colors.on_secondary.default.red}} {{colors.on_secondary.default.green}} {{colors.on_secondary.default.blue}}
          }

          ribbon_unselected {
            base {{colors.on_surface_variant.default.red}} {{colors.on_surface_variant.default.green}} {{colors.on_surface_variant.default.blue}}
            background {{colors.surface_container.default.red}} {{colors.surface_container.default.green}} {{colors.surface_container.default.blue}}
            emphasis_0 {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_1 {{colors.secondary.default.red}} {{colors.secondary.default.green}} {{colors.secondary.default.blue}}
            emphasis_2 {{colors.tertiary.default.red}} {{colors.tertiary.default.green}} {{colors.tertiary.default.blue}}
            emphasis_3 {{colors.on_surface.default.red}} {{colors.on_surface.default.green}} {{colors.on_surface.default.blue}}
          }

          ribbon_selected {
            base {{colors.on_primary.default.red}} {{colors.on_primary.default.green}} {{colors.on_primary.default.blue}}
            background {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_0 {{colors.on_primary.default.red}} {{colors.on_primary.default.green}} {{colors.on_primary.default.blue}}
            emphasis_1 {{colors.on_primary_container.default.red}} {{colors.on_primary_container.default.green}} {{colors.on_primary_container.default.blue}}
            emphasis_2 {{colors.on_surface.default.red}} {{colors.on_surface.default.green}} {{colors.on_surface.default.blue}}
            emphasis_3 {{colors.on_secondary.default.red}} {{colors.on_secondary.default.green}} {{colors.on_secondary.default.blue}}
          }

          table_title {
            base {{colors.on_secondary_container.default.red}} {{colors.on_secondary_container.default.green}} {{colors.on_secondary_container.default.blue}}
            background {{colors.secondary_container.default.red}} {{colors.secondary_container.default.green}} {{colors.secondary_container.default.blue}}
            emphasis_0 {{colors.on_secondary.default.red}} {{colors.on_secondary.default.green}} {{colors.on_secondary.default.blue}}
            emphasis_1 {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_2 {{colors.tertiary.default.red}} {{colors.tertiary.default.green}} {{colors.tertiary.default.blue}}
            emphasis_3 {{colors.on_surface.default.red}} {{colors.on_surface.default.green}} {{colors.on_surface.default.blue}}
          }

          table_cell_unselected {
            base {{colors.on_surface.default.red}} {{colors.on_surface.default.green}} {{colors.on_surface.default.blue}}
            background {{colors.surface.default.red}} {{colors.surface.default.green}} {{colors.surface.default.blue}}
            emphasis_0 {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_1 {{colors.secondary.default.red}} {{colors.secondary.default.green}} {{colors.secondary.default.blue}}
            emphasis_2 {{colors.tertiary.default.red}} {{colors.tertiary.default.green}} {{colors.tertiary.default.blue}}
            emphasis_3 {{colors.on_surface_variant.default.red}} {{colors.on_surface_variant.default.green}} {{colors.on_surface_variant.default.blue}}
          }

          table_cell_selected {
            base {{colors.on_secondary_container.default.red}} {{colors.on_secondary_container.default.green}} {{colors.on_secondary_container.default.blue}}
            background {{colors.secondary.default.red}} {{colors.secondary.default.green}} {{colors.secondary.default.blue}}
            emphasis_0 {{colors.on_secondary.default.red}} {{colors.on_secondary.default.green}} {{colors.on_secondary.default.blue}}
            emphasis_1 {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_2 {{colors.tertiary.default.red}} {{colors.tertiary.default.green}} {{colors.tertiary.default.blue}}
            emphasis_3 {{colors.on_surface.default.red}} {{colors.on_surface.default.green}} {{colors.on_surface.default.blue}}
          }

          list_unselected {
            base {{colors.on_surface.default.red}} {{colors.on_surface.default.green}} {{colors.on_surface.default.blue}}
            background {{colors.surface.default.red}} {{colors.surface.default.green}} {{colors.surface.default.blue}}
            emphasis_0 {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_1 {{colors.secondary.default.red}} {{colors.secondary.default.green}} {{colors.secondary.default.blue}}
            emphasis_2 {{colors.tertiary.default.red}} {{colors.tertiary.default.green}} {{colors.tertiary.default.blue}}
            emphasis_3 {{colors.on_surface_variant.default.red}} {{colors.on_surface_variant.default.green}} {{colors.on_surface_variant.default.blue}}
          }

          list_selected {
            base {{colors.on_secondary_container.default.red}} {{colors.on_secondary_container.default.green}} {{colors.on_secondary_container.default.blue}}
            background {{colors.secondary.default.red}} {{colors.secondary.default.green}} {{colors.secondary.default.blue}}
            emphasis_0 {{colors.on_secondary.default.red}} {{colors.on_secondary.default.green}} {{colors.on_secondary.default.blue}}
            emphasis_1 {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_2 {{colors.tertiary.default.red}} {{colors.tertiary.default.green}} {{colors.tertiary.default.blue}}
            emphasis_3 {{colors.on_surface.default.red}} {{colors.on_surface.default.green}} {{colors.on_surface.default.blue}}
          }

          frame_unselected {
            base {{colors.outline.default.red}} {{colors.outline.default.green}} {{colors.outline.default.blue}}
            background {{colors.surface.default.red}} {{colors.surface.default.green}} {{colors.surface.default.blue}}
            emphasis_0 {{colors.outline_variant.default.red}} {{colors.outline_variant.default.green}} {{colors.outline_variant.default.blue}}
            emphasis_1 {{colors.on_surface_variant.default.red}} {{colors.on_surface_variant.default.green}} {{colors.on_surface_variant.default.blue}}
            emphasis_2 {{colors.secondary.default.red}} {{colors.secondary.default.green}} {{colors.secondary.default.blue}}
            emphasis_3 {{colors.tertiary.default.red}} {{colors.tertiary.default.green}} {{colors.tertiary.default.blue}}
          }

          frame_selected {
            base {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            background {{colors.surface.default.red}} {{colors.surface.default.green}} {{colors.surface.default.blue}}
            emphasis_0 {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_1 {{colors.secondary.default.red}} {{colors.secondary.default.green}} {{colors.secondary.default.blue}}
            emphasis_2 {{colors.tertiary.default.red}} {{colors.tertiary.default.green}} {{colors.tertiary.default.blue}}
            emphasis_3 {{colors.on_surface.default.red}} {{colors.on_surface.default.green}} {{colors.on_surface.default.blue}}
          }

          frame_highlight {
            base {{colors.tertiary.default.red}} {{colors.tertiary.default.green}} {{colors.tertiary.default.blue}}
            background {{colors.surface.default.red}} {{colors.surface.default.green}} {{colors.surface.default.blue}}
            emphasis_0 {{colors.tertiary.default.red}} {{colors.tertiary.default.green}} {{colors.tertiary.default.blue}}
            emphasis_1 {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_2 {{colors.secondary.default.red}} {{colors.secondary.default.green}} {{colors.secondary.default.blue}}
            emphasis_3 {{colors.on_surface.default.red}} {{colors.on_surface.default.green}} {{colors.on_surface.default.blue}}
          }

          exit_code_success {
            base {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            background {{colors.surface.default.red}} {{colors.surface.default.green}} {{colors.surface.default.blue}}
            emphasis_0 {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_1 {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_2 {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
            emphasis_3 {{colors.primary.default.red}} {{colors.primary.default.green}} {{colors.primary.default.blue}}
          }

          exit_code_error {
            base {{colors.error.default.red}} {{colors.error.default.green}} {{colors.error.default.blue}}
            background {{colors.surface.default.red}} {{colors.surface.default.green}} {{colors.surface.default.blue}}
            emphasis_0 {{colors.error.default.red}} {{colors.error.default.green}} {{colors.error.default.blue}}
            emphasis_1 {{colors.error.default.red}} {{colors.error.default.green}} {{colors.error.default.blue}}
            emphasis_2 {{colors.error.default.red}} {{colors.error.default.green}} {{colors.error.default.blue}}
            emphasis_3 {{colors.error.default.red}} {{colors.error.default.green}} {{colors.error.default.blue}}
          }
        }
      }
    '';

    "noctalia/zellij.toml".text = ''
      [theme.templates.user.zellij]
      input_path = "templates/zellij-theme.kdl"
      output_path = "$XDG_CONFIG_HOME/zellij/themes/noctalia.kdl"
    '';
  };
}
