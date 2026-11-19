local mainMod = "SUPER"
local terminal = "alacritty"
local menu = "fuzzel"
local home = os.getenv("HOME")

local function bind(keys, dispatcher, description, opts)
    local options = opts or {}
    options.description = description
    return hl.bind(keys, dispatcher, options)
end

local function super(keys)
    return mainMod .. " + " .. keys
end

hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 12,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(f5b8daee)", "rgba(c9a7f0ee)" }, angle = 45 },
            inactive_border = "rgba(ffffff14)",
        },
        layout = "dwindle",
        resize_on_border = true,
        allow_tearing = true,
    },
    decoration = {
        rounding = 14,
        blur = {
            enabled = true,
            size = 8,
            passes = 2,
            new_optimizations = true,
            xray = true,
        },
        shadow = {
            enabled = true,
            range = 24,
            render_power = 3,
            color = "rgba(140a2899)",
        },
    },
    animations = { enabled = true },
    dwindle = { preserve_split = true },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 2,
    },
    input = {
        repeat_rate = 50,
        repeat_delay = 250,
    },
    cursor = { no_hardware_cursors = 1 },
})

pcall(dofile, home .. "/.local/state/aurora/hypr-palette.lua")

hl.curve("mac", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })
hl.curve("pop", { type = "bezier", points = { { 0.2, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "pop", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "mac", style = "popin 90%" })
hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "mac" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "mac" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "mac", style = "slide" })
hl.animation({ leaf = "layers", enabled = true, speed = 2.5, bezier = "mac", style = "fade" })

for _, namespace in ipairs({ "waybar", "launcher", "notifications" }) do
    hl.layer_rule({ match = { namespace = namespace }, blur = true, ignore_alpha = 0.2 })
end

hl.window_rule({ name = "tearing-terminal", match = { class = "^(Alacritty)$" }, immediate = true })
hl.window_rule({ name = "tearing-proton", match = { class = "^steam_app_" }, immediate = true })

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar -c ~/.config/waybar/config.jsonc")
    hl.exec_cmd("mako")
    hl.exec_cmd("~/.config/theme/aurora/wallpaper.sh --login")
    hl.exec_cmd("quickshell")
end)

bind(super("Return"), hl.dsp.exec_cmd(terminal), "Open terminal")
bind(super("Q"), hl.dsp.exec_cmd(terminal), "Open terminal")
bind(super("SHIFT + Q"), hl.dsp.window.close(), "Close window")
bind(super("D"), hl.dsp.exec_cmd(menu), "App launcher")
bind(super("SHIFT + C"), hl.dsp.reload_config(), "Reload Hyprland config")
bind(super("SHIFT + W"), hl.dsp.exec_cmd("~/.config/theme/aurora/wallpaper.sh"), "Shuffle wallpaper")
bind(super("slash"), hl.dsp.exec_cmd("~/.config/hypr/cheatsheet.sh"), "Show this shortcut cheatsheet")
bind(super("F1"), hl.dsp.exec_cmd("~/.config/hypr/cheatsheet.sh"), "Show this shortcut cheatsheet")
bind(super("mouse:272"), hl.dsp.window.drag(), "Drag window", { mouse = true })
bind(super("mouse:273"), hl.dsp.window.resize(), "Resize window", { mouse = true })

local directions = { H = "left", J = "down", K = "up", L = "right", Left = "left", Down = "down", Up = "up", Right = "right" }
for key, direction in pairs(directions) do
    bind(super(key), hl.dsp.focus({ direction = direction }), "Focus " .. direction)
    bind(super("SHIFT + " .. key), hl.dsp.window.move({ direction = direction }), "Move window " .. direction)
    bind(super("CTRL + " .. key), hl.dsp.window.move({ into_group = direction }), "Add window to the group " .. direction)
end

for i = 1, 10 do
    local key = i % 10
    bind(super(key), hl.dsp.focus({ workspace = i }), "Go to workspace " .. i)
    bind(super("SHIFT + " .. key), hl.dsp.window.move({ workspace = i }), "Move window to workspace " .. i)
end

bind(super("B"), hl.dsp.layout("preselect r"), "Next window opens to the right")
bind(super("V"), hl.dsp.layout("preselect d"), "Next window opens below")
bind(super("E"), hl.dsp.layout("togglesplit"), "Toggle split direction")
bind(super("W"), hl.dsp.group.toggle(), "Toggle tabbed group")
bind(super("S"), hl.dsp.group.next(), "Next tab in group")
bind(super("Tab"), hl.dsp.group.next(), "Next tab in group")
bind(super("SHIFT + Tab"), hl.dsp.group.prev(), "Previous tab in group")
bind(super("SHIFT + F"), hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), "Toggle maximize (keeps the bar)")
bind(super("F"), hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), "Toggle fullscreen")
bind(super("SHIFT + Space"), hl.dsp.window.float({ action = "toggle" }), "Toggle floating")
bind(super("Space"), hl.dsp.window.cycle_next(), "Cycle windows")

bind(super("SHIFT + minus"), hl.dsp.window.move({ workspace = "special:scratch", follow = false }), "Send window to scratchpad")
bind(super("minus"), hl.dsp.workspace.toggle_special("scratch"), "Show/hide scratchpad")

bind(super("R"), hl.dsp.submap("resize"), "Resize mode (arrows/HJKL, Esc to exit)")
hl.define_submap("resize", function()
    local steps = { H = { -10, 0 }, J = { 0, 10 }, K = { 0, -10 }, L = { 10, 0 }, Left = { -10, 0 }, Down = { 0, 10 }, Up = { 0, -10 }, Right = { 10, 0 } }
    for key, step in pairs(steps) do
        bind(key, hl.dsp.window.resize({ x = step[1], y = step[2], relative = true }), "Resize", { repeating = true })
    end
    bind("Return", hl.dsp.submap("reset"), "Leave resize mode")
    bind("Escape", hl.dsp.submap("reset"), "Leave resize mode")
end)

bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), "Mute", { locked = true })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), "Volume down", { locked = true, repeating = true })
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), "Volume up", { locked = true, repeating = true })
bind("XF86AudioMicMute", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), "Mute microphone", { locked = true })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), "Brightness down", { locked = true, repeating = true })
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), "Brightness up", { locked = true, repeating = true })

bind("Print", hl.dsp.exec_cmd("~/.config/scripts/screenshot.sh area"), "Screenshot area")
bind("SHIFT + Print", hl.dsp.exec_cmd("~/.config/scripts/screenshot.sh fullscreen"), "Screenshot screen")
bind(super("Print"), hl.dsp.exec_cmd("~/.config/scripts/screenshot.sh window"), "Screenshot window")
bind(super("SHIFT + R"), hl.dsp.exec_cmd("~/.config/scripts/screenrecord.sh area"), "Record area")
bind(super("SHIFT + CTRL + R"), hl.dsp.exec_cmd("~/.config/scripts/screenrecord.sh fullscreen"), "Record screen")
bind(super("SHIFT + ALT + R"), hl.dsp.exec_cmd("~/.config/scripts/screenrecord.sh area-no-audio"), "Record area without audio")
bind(super("SHIFT + F12"), hl.dsp.exec_cmd("~/.config/scripts/screenrecord.sh fullscreen noaudio"), "Record screen without audio")
bind(super("O"), hl.dsp.exec_cmd("~/.config/scripts/obs.sh"), "Open OBS")

dofile(home .. "/.config/hypr/host.lua")
