-- =========================
-- Hyprland config (Lua)
-- Wispie-chan edition 💜
-- Keybinds ported from config/mango/config.toml
-- Linked by home/hyprland.nix to ~/.config/hypr/hyprland.lua
-- =========================

local left = "desc:Samsung Electric Company LC24RG50 HNMT100624"
local right = "desc:HP Inc. OMEN by HP 25 3CQ95007KT"

-- Workspaces are per monitor: each monitor has its own 1-10, using ids
-- base + N. The base comes from the monitor's id (see home/hyprland.nix,
-- hypr-ws), so monitor 0 uses 1-10 and monitor 1 uses 11-20.

-- ##########
-- Moniteurs
-- ##########

hl.monitor({ output = left, mode = "1920x1080@143.981", position = "0x0", scale = 1, vrr = 1 })
hl.monitor({ output = right, mode = "1920x1080@143.992", position = "1920x0", scale = 1, vrr = 1 })

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
  cursor = {
    -- hyprcursor theme; Hyprland falls back to the XCursor theme of the same name.
    hyprcursor_theme = "Rio",
    hyprcursor_size = 24,
  },
})

-- ##########
-- Animations (rapides)
-- ##########

-- Ouverture et fermeture de fenêtres : courtes, sans rebond.
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2, bezier = "snap", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "snap", style = "popin 80%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2, bezier = "snap" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, bezier = "snap" })

-- Changement de workspace : plus rapide que la valeur par défaut.
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "snap", style = "slide" })

hl.curve("snap", { type = "bezier", points = { { 0.2, 0.9 }, { 0.1, 1.0 } } })

-- ##########
-- Autostart
-- ##########

hl.on("hyprland.start", function()
  hl.exec_cmd("waybar")
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("/home/wisp/.local/bin/polkit-gnome-agent")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Rio'")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- ##########
-- Raccourcis (identiques à Mango)
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
-- Workspaces (par écran, sur l'écran focus)
-- ##########

for i = 1, 9 do
  hl.bind("SUPER + " .. i, hl.dsp.exec_cmd("hypr-ws focus " .. i))
  hl.bind("SUPER + SHIFT + " .. i, hl.dsp.exec_cmd("hypr-ws move " .. i))
end
hl.bind("SUPER + 0", hl.dsp.exec_cmd("hypr-ws focus 10"))
hl.bind("SUPER + SHIFT + 0", hl.dsp.exec_cmd("hypr-ws move 10"))

-- ##########
-- Programmes
-- ##########

hl.bind("SUPER + t", hl.dsp.exec_cmd("kitty || alacritty || ghostty || foot"))
hl.bind("Print", hl.dsp.exec_cmd("noctalia msg screenshot-region"))
hl.bind("SUPER + SHIFT + r", hl.dsp.exec_cmd("screen-record toggle"))
hl.bind("SUPER + w", hl.dsp.exec_cmd("wallpaper-menu"))
hl.bind("SUPER + l", hl.dsp.exec_cmd("hyprlock"))

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
