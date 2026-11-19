hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@120", position = "0x0", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x1080", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.env("AQ_DRM_DEVICES", "/dev/dri/by-path/pci-0000:00:02.0-card")
hl.env("AURORA_SCREENS", "eDP-1")

hl.config({
    input = {
        kb_layout = "us,es",
        kb_options = "grp:win_space_toggle",
        sensitivity = 0.3,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            disable_while_typing = true,
        },
    },
})

hl.unbind("SUPER + Space")

hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
hl.workspace_rule({ workspace = "2", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-2", default = true })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-2" })
