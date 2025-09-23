#!/bin/bash
# Thunar CSS debugging script for persistent white backgrounds

echo "=== Thunar CSS Debug Helper ==="
echo "1. Launch Thunar with GTK Inspector"
echo "2. Check for GTK theme conflicts"
echo "3. Test with different GTK themes"
echo

# Function to launch Thunar with inspector
launch_inspector() {
    echo "Launching Thunar with GTK Inspector..."
    GTK_DEBUG=interactive thunar &
    echo "Use the inspector to:"
    echo "- Click the target icon"
    echo "- Click on white background elements"
    echo "- Note the CSS selector in the CSS tab"
    echo "- Look for computed styles overriding your rules"
}

# Function to check current GTK theme
check_theme() {
    echo "Current GTK theme settings:"
    echo "GTK3: $(gsettings get org.gnome.desktop.interface gtk-theme)"
    echo "Icon theme: $(gsettings get org.gnome.desktop.interface icon-theme)"
    echo "Cursor theme: $(gsettings get org.gnome.desktop.interface cursor-theme)"
    echo
}

# Function to test with different theme
test_theme() {
    local theme=$1
    echo "Testing with theme: $theme"
    gsettings set org.gnome.desktop.interface gtk-theme "$theme"
    thunar &
    echo "Press Enter when done testing..."
    read
    pkill thunar
}

# Function to reload GTK CSS
reload_css() {
    echo "Reloading GTK CSS..."
    pkill thunar
    sleep 1
    thunar &
    echo "Thunar restarted with updated CSS"
}

case "$1" in
    "inspector")
        launch_inspector
        ;;
    "check")
        check_theme
        ;;
    "test")
        if [ -z "$2" ]; then
            echo "Usage: $0 test <theme-name>"
            echo "Common themes: Adwaita, Adwaita-dark"
            exit 1
        fi
        test_theme "$2"
        ;;
    "reload")
        reload_css
        ;;
    *)
        echo "Usage: $0 {inspector|check|test <theme>|reload}"
        echo
        echo "Commands:"
        echo "  inspector - Launch Thunar with GTK Inspector"
        echo "  check     - Show current theme settings"
        echo "  test      - Test with different GTK theme"
        echo "  reload    - Reload Thunar with updated CSS"
        ;;
esac