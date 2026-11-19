hl.monitor({ output = "DP-1", mode = "1920x1080@143.98", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@74.97", position = "1920x0", scale = 1, transform = 1 })

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("AURORA_SCREENS", "DP-1")

for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = i <= 5 and "DP-1" or "HDMI-A-1", default = i == 1 or i == 6 })
end
