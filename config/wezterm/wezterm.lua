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

config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 12.0

config.default_prog = { 'fish' }
config.scrollback_lines = 10000

config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
config.window_background_opacity = 0.90
config.window_decorations = 'RESIZE'
config.window_close_confirmation = 'NeverPrompt'

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false

config.audible_bell = 'Disabled'

return config
