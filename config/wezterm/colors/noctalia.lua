-- Thème WezTerm rendu par Noctalia (Matugen).
-- Ne pas éditer le fichier généré : il est écrit dans ~/.config/wezterm/colors/noctalia.lua.
-- Géré par home/terminals.nix (noctalia/wezterm.toml).

return {
  foreground = "{{colors.on_surface.default.hex}}",
  background = "{{colors.surface.default.hex}}",

  cursor_bg = "{{colors.primary.default.hex}}",
  cursor_fg = "{{colors.on_primary.default.hex}}",
  cursor_border = "{{colors.primary.default.hex}}",

  selection_fg = "{{colors.on_secondary_container.default.hex}}",
  selection_bg = "{{colors.secondary_container.default.hex}}",

  scrollbar_thumb = "{{colors.outline_variant.default.hex}}",
  split = "{{colors.outline_variant.default.hex}}",
  compose_cursor = "{{colors.tertiary.default.hex}}",

  ansi = {
    "{{colors.surface_container_high.default.hex}}", -- black
    "{{colors.error.default.hex}}", -- red
    "{{colors.tertiary.default.hex}}", -- green
    "{{colors.secondary.default.hex}}", -- yellow
    "{{colors.primary.default.hex}}", -- blue
    "{{colors.on_primary_container.default.hex}}", -- magenta
    "{{colors.on_secondary_container.default.hex}}", -- cyan
    "{{colors.on_surface_variant.default.hex}}", -- white
  },

  brights = {
    "{{colors.outline.default.hex}}", -- black
    "{{colors.error.default.hex}}", -- red
    "{{colors.tertiary.default.hex}}", -- green
    "{{colors.secondary.default.hex}}", -- yellow
    "{{colors.primary.default.hex}}", -- blue
    "{{colors.on_primary_container.default.hex}}", -- magenta
    "{{colors.on_secondary_container.default.hex}}", -- cyan
    "{{colors.on_surface.default.hex}}", -- white
  },

  tab_bar = {
    background = "{{colors.surface_container_low.default.hex}}",

    active_tab = {
      bg_color = "{{colors.primary.default.hex}}",
      fg_color = "{{colors.on_primary.default.hex}}",
      intensity = "Bold",
    },

    inactive_tab = {
      bg_color = "{{colors.surface_container.default.hex}}",
      fg_color = "{{colors.on_surface_variant.default.hex}}",
    },

    inactive_tab_hover = {
      bg_color = "{{colors.surface_container_high.default.hex}}",
      fg_color = "{{colors.on_surface.default.hex}}",
    },

    new_tab = {
      bg_color = "{{colors.surface_container_low.default.hex}}",
      fg_color = "{{colors.on_surface_variant.default.hex}}",
    },

    new_tab_hover = {
      bg_color = "{{colors.surface_container_high.default.hex}}",
      fg_color = "{{colors.on_surface.default.hex}}",
    },
  },
}
