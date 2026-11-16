#!/usr/bin/env bash

# ==============================================================================
# File: scripts/lib/theme_apply.sh
# Purpose: Write dotfiles for Cursor & Icon themes (GTK3, GTK4, XCursor, GNOME)
# ==============================================================================

apply_cursor_dotfile() {
    local cursor_name="$1"

    # 1. Standard XCursor dotfile: ~/.icons/default/index.theme
    mkdir -p "$HOME/.icons/default"
    cat << EOF > "$HOME/.icons/default/index.theme"
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=$cursor_name
EOF

    # 2. GTK3 and GTK4 settings.ini dotfiles
    for gtk_dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
        mkdir -p "$gtk_dir"
        local ini_file="$gtk_dir/settings.ini"

        if [ ! -f "$ini_file" ]; then
            cat << EOF > "$ini_file"
[Settings]
gtk-cursor-theme-name=$cursor_name
EOF
        else
            if grep -q "gtk-cursor-theme-name" "$ini_file"; then
                sed -i "s/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=$cursor_name/" "$ini_file"
            else
                sed -i "/^\[Settings\]/a gtk-cursor-theme-name=$cursor_name" "$ini_file" 2>/dev/null || echo "gtk-cursor-theme-name=$cursor_name" >> "$ini_file"
            fi
        fi
    done

    # 3. GNOME dconf (gsettings)
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface cursor-theme "$cursor_name" 2>/dev/null || true
    fi
}

apply_icon_dotfile() {
    local icon_name="$1"

    # 1. GTK3 and GTK4 settings.ini dotfiles
    for gtk_dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
        mkdir -p "$gtk_dir"
        local ini_file="$gtk_dir/settings.ini"

        if [ ! -f "$ini_file" ]; then
            cat << EOF > "$ini_file"
[Settings]
gtk-icon-theme-name=$icon_name
EOF
        else
            if grep -q "gtk-icon-theme-name" "$ini_file"; then
                sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=$icon_name/" "$ini_file"
            else
                sed -i "/^\[Settings\]/a gtk-icon-theme-name=$icon_name" "$ini_file" 2>/dev/null || echo "gtk-icon-theme-name=$icon_name" >> "$ini_file"
            fi
        fi
    done

    # 2. GNOME dconf (gsettings)
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface icon-theme "$icon_name" 2>/dev/null || true
    fi
}

