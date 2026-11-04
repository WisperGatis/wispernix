-- =========================
-- Hyprland config (Lua)
-- Wispie-chan edition 💜
-- Keybinds ported from config/mango/config.toml
-- Linked by home/hyprland.nix to ~/.config/hypr/hyprland.lua
-- =========================

local left = "desc:Samsung Electric Company LC24RG50 HNMT100624"
local right = "desc:HP Inc. OMEN by HP 25 3CQ95007KT"

-- ##########
-- Moniteurs
-- ##########

hl.monitor({ output = left, mode = "1920x1080@143.981", position = "0x0", scale = 1, vrr = 1 })
hl.monitor({ output = right, mode = "1920x1080@143.992", position = "1920x0", scale = 1, vrr = 1 })

-- ##################################
-- Apparence / gaps / bordures / flou
-- ##################################

-- Shader d'écran : celui choisi avec shader-menu (SUPER + c), sinon la saturation par défaut.
-- Fichier vide = shader désactivé.
local shader = os.getenv("HOME") .. "/.config/hypr/shaders/vibrance.frag"
local state = io.open((os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/hypr-shader", "r")
if state then
  local saved = state:read("*l")
  state:close()
  if saved then shader = saved end
end

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 3,
  },
  decoration = {
    rounding = 0,
    -- Shaders dans config/hyprland/shaders/ (liés dans ~/.config/hypr/shaders).
    screen_shader = shader,
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
-- Animations (rapides)
-- ##########

-- La courbe doit être déclarée avant les animations qui l'utilisent.
hl.curve("snap", { type = "bezier", points = { { 0.2, 0.9 }, { 0.1, 1.0 } } })

-- Ouverture et fermeture de fenêtres : courtes, sans rebond.
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2, bezier = "snap", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "snap", style = "popin 80%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2, bezier = "snap" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, bezier = "snap" })

-- Changement de workspace : plus rapide que la valeur par défaut.
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "snap", style = "slide" })

-- Déplacement et redimensionnement de fenêtres : rapides, sans rebond.
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "snap", style = "slide" })

-- ##########
-- Autostart
-- ##########

hl.on("hyprland.start", function()
  hl.exec_cmd("swaync")
  hl.exec_cmd("waybar")
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("/home/wisp/.local/bin/polkit-gnome-agent")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'remielle_black'")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- ##########
-- Raccourcis (identiques à Mango)
-- ##########

hl.bind("SUPER + space", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind("SUPER + v", hl.dsp.exec_cmd("clipboard-menu"))
hl.bind("SUPER + n", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind("SUPER + period", hl.dsp.exec_cmd("rofi -show emoji -modi emoji"))

-- ##########
-- Fenêtres / navigation
-- ##########

hl.bind("SUPER + q", hl.dsp.window.close())
hl.bind("SUPER + Tab", hl.dsp.window.cycle_next())
hl.bind("ALT + Tab", hl.dsp.exec_cmd("rofi -show window"))
hl.bind("SUPER + SHIFT + f", hl.dsp.window.fullscreen())
hl.bind("SUPER + f", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + a", hl.dsp.focus({ monitor = "l" }))
hl.bind("SUPER + SHIFT + d", hl.dsp.focus({ monitor = "r" }))

-- ##########
-- Workspaces (par écran, sur l'écran focus)
-- ##########

for i = 1, 9 do
  hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
end
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = "10" }))

-- ##########
-- Programmes
-- ##########

hl.bind("SUPER + t", hl.dsp.exec_cmd("kitty || alacritty || ghostty || foot"))
hl.bind("Print", hl.dsp.exec_cmd("screenshot region"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("screenshot full"))
hl.bind("SUPER + SHIFT + s", hl.dsp.exec_cmd("screenshot menu"))
hl.bind("SUPER + SHIFT + r", hl.dsp.exec_cmd("screen-record toggle"))
hl.bind("SUPER + w", hl.dsp.exec_cmd("wallpaper-menu"))
hl.bind("SUPER + c", hl.dsp.exec_cmd("shader-menu"))
hl.bind("SUPER + SHIFT + c", hl.dsp.exec_cmd("shader-menu off"))
hl.bind("SUPER + l", hl.dsp.exec_cmd("hyprlock"))

-- ##########
-- Multimédia (volume, micro, lecture) avec OSD via volume-ctl
-- ##########

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volume-ctl up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volume-ctl down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("volume-ctl mute"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("volume-ctl mic-mute"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Secours pour un clavier sans touches multimédia.
hl.bind("SUPER + F10", hl.dsp.exec_cmd("volume-ctl mute"))
hl.bind("SUPER + F11", hl.dsp.exec_cmd("volume-ctl down"), { repeating = true })
hl.bind("SUPER + F12", hl.dsp.exec_cmd("volume-ctl up"), { repeating = true })

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
