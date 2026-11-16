#!/usr/bin/env bash

# ==============================================================================
# Script: scripts/icons.sh
# Purpose: Preview, install and apply icon themes (generates dotfiles)
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
ICONS_SRC_DIR="$SCRIPT_DIR/assets/icons"
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
    local size="${2:-45x18}"
    if [ -f "$img" ] && command -v chafa &> /dev/null; then
        echo ""
        chafa --size="$size" "$img" 2>/dev/null || true
        echo ""
    fi
}

mkdir -p "$ICONS_DEST" 2>/dev/null || true

echo -e "${COLOR_CYAN}==================================================================${COLOR_RESET}"
echo -e "${COLOR_BOLD}         $(t icon_banner)         ${COLOR_RESET}"
echo -e "${COLOR_CYAN}==================================================================${COLOR_RESET}"
echo "  1) $(t icon_opt_1)"
echo "  2) $(t icon_opt_2)"
echo "  3) $(t icon_opt_3)"
echo "  p) $(t icon_preview_opt)"
echo "  0) $(t exit)"
echo ""
read -rp "$(t icon_select_prompt)" pick

pick="${pick:-1}"

if [ "$pick" == "p" ] || [ "$pick" == "P" ]; then
    echo -e "\n${COLOR_CYAN}--- 1. Candy Icons ---${COLOR_RESET}"
    show_image "$ICONS_SRC_DIR/candy_icons.png" "45x18"
    echo -e "${COLOR_CYAN}--- 2. Tela Icon Theme ---${COLOR_RESET}"
    show_image "$ICONS_SRC_DIR/tela_icons.png" "45x18"
    echo -e "${COLOR_CYAN}--- 3. Fluent Icon Theme ---${COLOR_RESET}"
    show_image "$ICONS_SRC_DIR/fluent_icons.png" "45x18"
    read -rp "$(t enter_to_continue)" _
    exec "$0"
fi

case "$pick" in
    1)
        log_info "Selected: Candy Icons"
        show_image "$ICONS_SRC_DIR/candy_icons.png" "45x18"
        if [ ! -d "$ICONS_DEST/candy-icons" ] && [ ! -d "/usr/share/icons/candy-icons" ]; then
            log_info "Cloning Candy Icons from GitHub..."
            git clone --depth=1 https://github.com/EliverLara/candy-icons.git "$ICONS_DEST/candy-icons"
        fi
        apply_icon_dotfile "candy-icons"
        log_success "$(t icon_applied) candy-icons"
        ;;
    2)
        log_info "Selected: Tela Icon Theme"
        show_image "$ICONS_SRC_DIR/tela_icons.png" "45x18"
        TMP_TELA="$(mktemp -d /tmp/tela-icons.XXXXXX)"
        git clone --depth=1 https://github.com/vinceliuice/Tela-icon-theme.git "$TMP_TELA"
        (
            cd "$TMP_TELA" || exit 1
            ./install.sh -d "$ICONS_DEST"
        )
        rm -rf "$TMP_TELA"
        apply_icon_dotfile "Tela-dark"
        log_success "$(t icon_applied) Tela-dark"
        ;;
    3)
        log_info "Selected: Fluent Icon Theme"
        show_image "$ICONS_SRC_DIR/fluent_icons.png" "45x18"
        TMP_FLUENT="$(mktemp -d /tmp/fluent-icons.XXXXXX)"
        git clone --depth=1 https://github.com/vinceliuice/Fluent-icon-theme.git "$TMP_FLUENT"
        (
            cd "$TMP_FLUENT" || exit 1
            ./install.sh -d "$ICONS_DEST"
        )
        rm -rf "$TMP_FLUENT"
        apply_icon_dotfile "Fluent-dark"
        log_success "$(t icon_applied) Fluent-dark"
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
