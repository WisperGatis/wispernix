-- =========================
-- Hyprland config (Lua)
-- Wispie-chan edition 💜
-- Keybinds ported from config/mango/config.toml
-- Linked by home/hyprland.nix to ~/.config/hypr/hyprland.lua
-- =========================

local left = "desc:Samsung Electric Company LC24RG50 HNMT100624"
local right = "desc:HP Inc. OMEN by HP 25 3CQ95007KT"

local wallpapers = os.getenv("HOME") .. "/Pictures/Wallpapers"

-- ##########
-- Moniteurs
-- ##########

hl.monitor({ output = left, mode = "1920x1080@143.981", position = "0x0", scale = 1, vrr = 1 })
hl.monitor({ output = right, mode = "1920x1080@143.992", position = "1920x0", scale = 1, vrr = 1 })

-- ##########################
-- Workspaces par écran
-- 1-5 sur le gauche, 6-10 sur le droit
-- ##########################

for i = 1, 5 do
  hl.workspace_rule({ workspace = tostring(i), monitor = left, persistent = true })
end
for i = 6, 10 do
  hl.workspace_rule({ workspace = tostring(i), monitor = right, persistent = true })
end

-- ##################################
-- Apparence / gaps / bordures / flou
-- ##################################

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 3,
  },
  decoration = {
    rounding = 14,
    active_opacity = 0.92,
    inactive_opacity = 0.75,
    blur = {
      enabled = true,
      size = 6,
      passes = 2,
    },
  },
  input = {
    kb_layout = "ch",
    kb_variant = "fr",
  },
})

-- ##########
-- Autostart
-- ##########

hl.on("hyprland.start", function()
  hl.exec_cmd("waybar")
  hl.exec_cmd("swww-daemon")
  hl.exec_cmd("noctalia")
  hl.exec_cmd("/home/wisp/.local/bin/polkit-gnome-agent")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Rio'")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- ##########
-- Raccourcis Noctalia (identiques à Mango)
-- ##########

hl.bind("SUPER + space", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind("SUPER + o", hl.dsp.exec_cmd("noctalia msg settings-toggle"))
hl.bind("SUPER + v", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
hl.bind("SUPER + e", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))

-- ##########
-- Fenêtres / navigation
-- ##########

hl.bind("SUPER + q", hl.dsp.window.close())
hl.bind("SUPER + Tab", hl.dsp.window.cycle_next())
hl.bind("SUPER + SHIFT + f", hl.dsp.window.fullscreen())
hl.bind("SUPER + f", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + a", hl.dsp.focus({ monitor = "l" }))
hl.bind("SUPER + SHIFT + d", hl.dsp.focus({ monitor = "r" }))

-- ##########
-- Workspaces
-- ##########

for i = 1, 9 do
  hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
end
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = "10" }))

-- ##########
-- Programmes
-- ##########

hl.bind("SUPER + t", hl.dsp.exec_cmd("kitty || alacritty || ghostty || foot"))
hl.bind("Print", hl.dsp.exec_cmd("noctalia msg screenshot-region"))
hl.bind("SUPER + SHIFT + r", hl.dsp.exec_cmd("screen-record toggle"))
hl.bind("SUPER + w", hl.dsp.exec_cmd("wallpaper-menu"))

-- ##########
-- Système
-- ##########

hl.bind("SUPER + r", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("SUPER + m", hl.dsp.exit())

-- ##########
-- Souris
-- ##########

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
