#!/usr/bin/env bash

# ==============================================================================
# Script: scripts/cursors.sh
# Purpose: Preview, install and apply cursor themes (generates dotfiles)
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
CURSORS_DIR="$SCRIPT_DIR/assets/cursors"
ICONS_DEST="$HOME/.local/share/icons"

# Load i18n and theme dotfile helper
source "$SCRIPT_DIR/scripts/lib/i18n.sh"
source "$SCRIPT_DIR/scripts/lib/theme_apply.sh"

log_info() { echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} $1"; }
log_success() { echo -e "${COLOR_GREEN}$(t success)${COLOR_RESET} $1"; }
log_warning() { echo -e "${COLOR_YELLOW}$(t warning)${COLOR_RESET} $1"; }
log_error() { echo -e "${COLOR_RED}$(t error)${COLOR_RESET} $1"; }

show_image() {
    local img="$1"
    local size="${2:-40x16}"
    if [ -f "$img" ] && command -v chafa &> /dev/null; then
        echo ""
        chafa --size="$size" "$img" 2>/dev/null || true
        echo ""
    fi
}

mkdir -p "$ICONS_DEST" 2>/dev/null || true

echo -e "${COLOR_CYAN}==================================================================${COLOR_RESET}"
echo -e "${COLOR_BOLD}         $(t cursor_banner)             ${COLOR_RESET}"
echo -e "${COLOR_CYAN}==================================================================${COLOR_RESET}"
echo "  1) $(t cursor_opt_1)"
echo "  2) $(t cursor_opt_2)"
echo "  3) $(t cursor_opt_3)"
echo "  p) $(t cursor_preview_opt)"
echo "  0) $(t exit)"
echo ""
read -rp "$(t cursor_select_prompt)" pick

pick="${pick:-1}"

if [ "$pick" == "p" ] || [ "$pick" == "P" ]; then
    echo -e "\n${COLOR_CYAN}--- 1. Oreo Cursors ---${COLOR_RESET}"
    show_image "$CURSORS_DIR/oreo.png" "45x18"
    echo -e "${COLOR_CYAN}--- 2. Bibata Extra / Rainbow ---${COLOR_RESET}"
    show_image "$CURSORS_DIR/bibata_extra.png" "45x18"
    echo -e "${COLOR_CYAN}--- 3. Banana Cursor ---${COLOR_RESET}"
    show_image "$CURSORS_DIR/banana.png" "45x18"
    read -rp "$(t enter_to_continue)" _
    exec "$0"
fi

case "$pick" in
    1)
        log_info "Selected: Oreo Cursors"
        show_image "$CURSORS_DIR/oreo.png" "40x16"
        if command -v paru &> /dev/null; then
            paru -S --needed --noconfirm oreo-cursors-git
        fi
        apply_cursor_dotfile "oreo_spark_pink_cursors"
        log_success "$(t cursor_applied) oreo_spark_pink_cursors"
        ;;
    2)
        log_info "Selected: Bibata Extra / Rainbow"
        show_image "$CURSORS_DIR/bibata_extra.png" "40x16"
        if command -v paru &> /dev/null; then
            paru -S --needed --noconfirm bibata-cursor-theme-bin
        fi
        apply_cursor_dotfile "Bibata-Modern-Classic"
        log_success "$(t cursor_applied) Bibata-Modern-Classic"
        ;;
    3)
        log_info "Selected: Banana Cursor"
        show_image "$CURSORS_DIR/banana.png" "40x16"
        TMP_BANANA="$(mktemp -d /tmp/banana-cursor.XXXXXX)"
        git clone --depth=1 https://github.com/mdomlop/banana-cursor.git "$TMP_BANANA" 2>/dev/null || true
        if [ -d "$TMP_BANANA" ]; then
            cp -r "$TMP_BANANA" "$ICONS_DEST/Banana-Cursor" 2>/dev/null || true
            rm -rf "$TMP_BANANA"
        fi
        apply_cursor_dotfile "Banana-Cursor"
        log_success "$(t cursor_applied) Banana-Cursor"
        ;;
    0)
        log_info "$(t exit)"
        exit 0
        ;;
    *)
        log_error "$(t invalid_choice)"
        exit 1
        ;;
esac
