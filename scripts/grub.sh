#!/usr/bin/env bash

# ==============================================================================
# Script: scripts/grub.sh
# Purpose: Preview and install GRUB Bootloader themes from assets/grup_menu/
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
GRUB_SRC_DIR="$SCRIPT_DIR/assets/grup_menu"

source "$SCRIPT_DIR/scripts/lib/i18n.sh"

log_info() { echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} $1"; }
log_success() { echo -e "${COLOR_GREEN}$(t success)${COLOR_RESET} $1"; }
log_warning() { echo -e "${COLOR_YELLOW}$(t warning)${COLOR_RESET} $1"; }
log_error() { echo -e "${COLOR_RED}$(t error)${COLOR_RESET} $1"; }

show_image() {
    local img="$1"
    local size="${2:-45x16}"
    if [ -f "$img" ] && command -v chafa &> /dev/null; then
        echo ""
        chafa --size="$size" "$img" 2>/dev/null || true
        echo ""
    fi
}

echo -e "${COLOR_CYAN}==================================================================${COLOR_RESET}"
echo -e "${COLOR_BOLD}         $(t grub_banner)        ${COLOR_RESET}"
echo -e "${COLOR_CYAN}==================================================================${COLOR_RESET}"
log_warning "$(t grub_warn)"
echo ""
echo "  1) $(t grub_opt_1)"
echo "  2) $(t grub_opt_2)"
echo "  3) $(t grub_opt_3)"
echo "  p) Preview in terminal"
echo "  0) $(t exit)"
echo ""
read -rp "$(t select_prompt) [Default: 1]: " pick

pick="${pick:-1}"

if [ "$pick" == "p" ] || [ "$pick" == "P" ]; then
    echo -e "\n${COLOR_CYAN}--- 1. Wintux Dualboot GRUB Theme ---${COLOR_RESET}"
    show_image "$GRUB_SRC_DIR/wintux_grub.gif" "45x16"
    echo -e "${COLOR_CYAN}--- 2. Blur GRUB Theme ---${COLOR_RESET}"
    show_image "$GRUB_SRC_DIR/blur_grub.png" "45x16"
    echo -e "${COLOR_CYAN}--- 3. Elegant Wave GRUB Theme ---${COLOR_RESET}"
    show_image "$GRUB_SRC_DIR/elegant_wave_grub.png" "45x16"
    read -rp "$(t enter_to_continue)" _
    exec "$0"
fi

case "$pick" in
    1)
        log_info "Selected: Wintux Dualboot GRUB Theme"
        show_image "$GRUB_SRC_DIR/wintux_grub.gif" "45x16"
        TMP_WINTUX="$(mktemp -d /tmp/wintux-grub.XXXXXX)"
        git clone --depth=1 https://github.com/Harshil-Anuwadia/wintux-dualboot-grub-theme-updated.git "$TMP_WINTUX"
        (
            cd "$TMP_WINTUX" || exit 1
            sudo bash ./universal-installer.sh
        )
        rm -rf "$TMP_WINTUX"
        log_success "$(t grub_applied)"
        ;;
    2)
        log_info "Selected: Blur GRUB Theme"
        show_image "$GRUB_SRC_DIR/blur_grub.png" "45x16"
        TMP_BLUR="$(mktemp -d /tmp/blur-grub.XXXXXX)"
        git clone --depth=1 https://github.com/vinceliuice/grub2-themes.git "$TMP_BLUR"
        (
            cd "$TMP_BLUR" || exit 1
            sudo ./install.sh -t tela -s 1080p
        )
        rm -rf "$TMP_BLUR"
        log_success "$(t grub_applied)"
        ;;
    3)
        log_info "Selected: Elegant Wave GRUB Theme"
        show_image "$GRUB_SRC_DIR/elegant_wave_grub.png" "45x16"
        TMP_VIMIX="$(mktemp -d /tmp/vimix-grub.XXXXXX)"
        git clone --depth=1 https://github.com/vinceliuice/grub2-themes.git "$TMP_VIMIX"
        (
            cd "$TMP_VIMIX" || exit 1
            sudo ./install.sh -t vimix -s 1080p
        )
        rm -rf "$TMP_VIMIX"
        log_success "$(t grub_applied)"
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
