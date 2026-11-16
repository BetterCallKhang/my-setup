#!/usr/bin/env bash

# ==============================================================================
# Script: scripts/wallpapers.sh
# Purpose: Preview and apply desktop wallpaper from assets/wallpapers/images/
# ==============================================================================

set -uo pipefail

COLOR_RESET="\033[0m"
COLOR_GREEN="\033[1;32m"
COLOR_BLUE="\033[1;34m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[1;31m"
COLOR_CYAN="\033[1;36m"
COLOR_BOLD="\033[1m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WP_SRC="$SCRIPT_DIR/assets/wallpapers/images"
WALLPAPERS_DEST="$HOME/.local/share/backgrounds"

source "$SCRIPT_DIR/scripts/lib/i18n.sh"

log_info() { echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} $1"; }
log_success() { echo -e "${COLOR_GREEN}$(t success)${COLOR_RESET} $1"; }
log_warning() { echo -e "${COLOR_YELLOW}$(t warning)${COLOR_RESET} $1"; }
log_error() { echo -e "${COLOR_RED}$(t error)${COLOR_RESET} $1"; }

show_image() {
    local img="$1"
    local size="${2:-45x18}"
    if [ -f "$img" ] && command -v chafa &> /dev/null; then
        echo ""
        chafa --size="$size" "$img" 2>/dev/null || true
        echo ""
    fi
}

mkdir -p "$WALLPAPERS_DEST" 2>/dev/null || true

if [ ! -d "$WP_SRC" ]; then
    log_error "Wallpaper directory not found: $WP_SRC"
    exit 1
fi

echo -e "${COLOR_CYAN}==================================================================${COLOR_RESET}"
echo -e "${COLOR_BOLD}         $(t wp_banner)           ${COLOR_RESET}"
echo -e "${COLOR_CYAN}==================================================================${COLOR_RESET}"

images=()
while IFS= read -r f; do
    [ -n "$f" ] && images+=("$f")
done < <(find "$WP_SRC" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | sort)

if [ ${#images[@]} -eq 0 ]; then
    log_warning "No images found in $WP_SRC."
    exit 0
fi

default_index=1
for i in "${!images[@]}"; do
    if [[ "${images[$i]}" == *"127212220_p0.png"* ]]; then
        default_index=$((i+1))
        break
    fi
done

idx=1
for img in "${images[@]}"; do
    mark=""
    if [ "$idx" -eq "$default_index" ]; then
        mark=" [Default]"
    fi
    printf "  %2d) %s%s\n" "$idx" "$(basename "$img")" "$mark"
    ((idx++))
done
echo "   p) $(t wp_preview_opt)"
echo "   0) $(t exit)"
echo ""
read -rp "$(t wp_select_prompt) [Default: $default_index]: " pick

pick="${pick:-$default_index}"

if [ "$pick" == "p" ] || [ "$pick" == "P" ]; then
    if ! command -v chafa &> /dev/null; then
        log_warning "Install 'chafa' to view image previews in terminal (paru -S chafa)."
    else
        for img in "${images[@]}"; do
            echo -e "\n${COLOR_CYAN}--- $(basename "$img") ---${COLOR_RESET}"
            show_image "$img" "50x20"
        done
    fi
    read -rp "$(t enter_to_continue)" _
    exec "$0"
fi

if [[ "$pick" =~ ^[0-9]+$ ]] && [ "$pick" -ge 1 ] && [ "$pick" -le "${#images[@]}" ]; then
    selected="${images[$((pick-1))]}"
    cp "$selected" "$WALLPAPERS_DEST/"
    dest_file="$WALLPAPERS_DEST/$(basename "$selected")"

    log_info "Selected: $(basename "$dest_file")"
    show_image "$dest_file" "45x18"

    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.background picture-uri "file://$dest_file" 2>/dev/null || true
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$dest_file" 2>/dev/null || true
        log_success "$(t wp_applied) $(basename "$dest_file")"
    fi
elif [ "$pick" == "0" ]; then
    log_info "$(t exit)"
    exit 0
else
    log_error "$(t invalid_choice)"
    exit 1
fi
