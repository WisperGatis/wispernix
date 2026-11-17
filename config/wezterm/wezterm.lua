-- WezTerm : même réglage que kitty / alacritty / foot (home/terminals.nix).
-- Couleurs : Noctalia écrit ~/.config/wezterm/colors/noctalia.lua, WezTerm le recharge seul.

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Thème Noctalia, avec repli sur un thème intégré si le fichier n'existe pas encore.
local ok, noctalia = pcall(require, 'colors.noctalia')
if ok then
  config.colors = noctalia
else
  config.color_scheme = 'Catppuccin Mocha'
  wezterm.log_warn('Noctalia colors unavailable: ' .. tostring(noctalia))
end

-- Police et texte
config.font = wezterm.font_with_fallback {
  'JetBrainsMono Nerd Font',
  'Noto Color Emoji',
}
config.font_size = 12.0
config.line_height = 1.1
config.cell_width = 1.0

-- Curseur doux
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = 'Ease'
config.cursor_blink_ease_out = 'Ease'
config.animation_fps = 60

-- Shell et historique
config.default_prog = { 'fish' }
config.scrollback_lines = 10000

-- Fenêtre : marges généreuses, léger voile transparent
config.window_padding = { left = 14, right = 14, top = 12, bottom = 10 }
config.window_background_opacity = 0.90
config.window_decorations = 'RESIZE'
config.window_close_confirmation = 'NeverPrompt'
config.window_frame = {
  font = wezterm.font { family = 'JetBrainsMono Nerd Font', weight = 'Bold' },
  font_size = 11.0,
}

-- Panneaux inactifs légèrement estompés pour mieux voir le focus
config.inactive_pane_hsb = {
  saturation = 0.85,
  brightness = 0.75,
}

-- Barre d'onglets : style moderne, sans bouton "+"
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

-- Onglets en pastilles arrondies, couleurs tirées du thème Noctalia.
wezterm.on('format-tab-title', function(tab, _tabs, _panes, cfg, hover, _max_width)
  local tb = cfg.colors and cfg.colors.tab_bar
  if not tb then
    return nil -- repli sur le rendu par défaut de WezTerm
  end

  local bg, fg
  if tab.is_active then
    bg, fg = tb.active_tab.bg_color, tb.active_tab.fg_color
  elseif hover then
    bg, fg = tb.inactive_tab_hover.bg_color, tb.inactive_tab_hover.fg_color
  else
    bg, fg = tb.inactive_tab.bg_color, tb.inactive_tab.fg_color
  end

  local title = tab.active_pane.title
  return {
    { Background = { Color = tb.background } },
    { Foreground = { Color = bg } },
    { Text = '\u{E0B6}' },
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
    { Text = ' ' .. (tab.tab_index + 1) .. '  ' .. title .. ' ' },
    { Background = { Color = tb.background } },
    { Foreground = { Color = bg } },
    { Text = '\u{E0B4}' },
  }
end)

-- Interactions
config.audible_bell = 'Disabled'
config.warn_about_missing_glyphs = false

return config
