-- Personal Hyprland configuration. Reload with SUPER + SHIFT + R.
local colors = require("colors")

local terminal = "kitty"
local file_manager = "dolphin"
local launcher = "wofi --show drun"
local main_mod = "SUPER"

-- Keep applications compact and consistent instead of accepting automatic
-- fractional scaling, which makes toolkit text unnecessarily large here.
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "1",
})

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.on("hyprland.start", function()
    hl.exec_cmd("command -v quickshell >/dev/null 2>&1 && quickshell")
    hl.exec_cmd("command -v nm-applet >/dev/null 2>&1 && nm-applet --indicator")
    hl.exec_cmd("command -v hyprpaper >/dev/null 2>&1 && hyprpaper")
    hl.exec_cmd("command -v hypridle >/dev/null 2>&1 && hypridle")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
end)

hl.config({
    general = {
        -- Compact layout with fixed profile colors.
        gaps_in = 8,
        gaps_out = 22,
        border_size = 1,
        col = {
            active_border = "rgba(585858ff)",
            inactive_border = "rgba(585858ff)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = false,
            range = 12,
            render_power = 3,
            color = "rgba(" .. colors.shadow .. "99)",
        },
        blur = {
            enabled = true,
            size = 7,
            passes = 3,
            vibrancy = 0.0,
        },
    },
    animations = { enabled = true },
    dwindle = {
        preserve_split = true,
        smart_split = false,
    },
    input = {
        kb_layout = "no",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
            tap_to_click = true,
        },
    },
    misc = {
        font_family = "JetBrainsMono Nerd Font",
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})

hl.curve("snappy", { type = "bezier", points = { {0.2, 0.8}, {0.2, 1} } })
hl.curve("smooth", { type = "bezier", points = { {0.4, 0}, {0.2, 1} } })
hl.animation({ leaf = "global", enabled = true, speed = 8, bezier = "smooth" })
hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "snappy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "snappy", style = "popin 88%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "smooth", style = "popin 88%" })
hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "smooth" })
hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "smooth" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "smooth", style = "slidevert" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Keep the top bar's workspace buttons 1–10 visible, even when empty.
for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end

-- Applications and session controls.
hl.bind(main_mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(main_mod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(main_mod .. " + C", hl.dsp.exec_cmd("codium"))
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(file_manager))
hl.bind(main_mod .. " + R", hl.dsp.exec_cmd(launcher))
hl.bind("Print", hl.dsp.exec_cmd('mkdir -p "$HOME/Pictures/Screenshots" && grim "$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png"'))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd('mkdir -p "$HOME/Pictures/Screenshots" && grim -g "$(slurp)" "$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png"'))
hl.bind(main_mod .. " + SHIFT + W", hl.dsp.global("quickshell:wallpaper-picker"))
hl.bind(main_mod .. " + SHIFT + N", hl.dsp.global("quickshell:notification-center"))
hl.bind(main_mod .. " + Q", hl.dsp.window.close())
hl.bind(main_mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(main_mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(main_mod .. " + SHIFT + L", hl.dsp.exec_cmd("command -v hyprlock >/dev/null 2>&1 && hyprlock"))
hl.bind(main_mod .. " + SHIFT + Q", hl.dsp.exit())

-- Focus and move windows with either vim keys or arrows.
local directions = { h = "left", l = "right", k = "up", j = "down" }
for key, direction in pairs(directions) do
    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ direction = direction }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end
for _, direction in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(main_mod .. " + " .. direction, hl.dsp.focus({ direction = direction }))
    hl.bind(main_mod .. " + SHIFT + " .. direction, hl.dsp.window.move({ direction = direction }))
end

for i = 1, 10 do
    local key = i % 10
    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(main_mod .. " + S", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(main_mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))
hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop keys. Commands safely do nothing until their optional utility is installed.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("command -v brightnessctl >/dev/null 2>&1 && brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("command -v brightnessctl >/dev/null 2>&1 && brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("command -v playerctl >/dev/null 2>&1 && playerctl next"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("command -v playerctl >/dev/null 2>&1 && playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("command -v playerctl >/dev/null 2>&1 && playerctl previous"), { locked = true })

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Glass effect for Quickshell's transparent top bar.
hl.layer_rule({
    name = "quickshell-topbar-glass",
    match = { namespace = "quickshell" },
    blur = true,
    ignore_alpha = 0.1,
})
