#!/usr/bin/env bash

# ==============================================================================
# File: scripts/lib/i18n.sh
# Purpose: Language strings management (English [Default] and Vietnamese)
# ==============================================================================

LANG_CONFIG_DIR="$HOME/.config/dotfiles"
LANG_CONFIG_FILE="$LANG_CONFIG_DIR/lang"

# Load saved language or fallback to English
if [ -f "$LANG_CONFIG_FILE" ]; then
    APP_LANG="$(cat "$LANG_CONFIG_FILE" 2>/dev/null || echo "en")"
else
    APP_LANG="${DOTFILES_LANG:-en}"
fi

# Function to switch language
set_language() {
    local target="$1"
    if [[ "$target" == "vi" || "$target" == "en" ]]; then
        APP_LANG="$target"
        mkdir -p "$LANG_CONFIG_DIR" 2>/dev/null || true
        echo "$target" > "$LANG_CONFIG_FILE" 2>/dev/null || true
    fi
}

# Translation helper
t() {
    local key="$1"

    if [ "$APP_LANG" == "vi" ]; then
        case "$key" in
            # Common
            info) echo "[THONG TIN]" ;;
            success) echo "[HOAN TAT]" ;;
            warning) echo "[CHU Y]" ;;
            error) echo "[LOI]" ;;
            back) echo "Quay lai" ;;
            exit) echo "Thoat" ;;
            invalid_choice) echo "Lua chon khong hop le." ;;
            cancelled) echo "Thao tac da bi huy." ;;
            confirm_prompt) echo "Tiep tuc thuc hien? [y/N]: " ;;
            enter_to_continue) echo "Nhan Enter de tiep tuc..." ;;
            select_prompt) echo "Nhap lua chon cua ban: " ;;

            # Installer
            inst_checking_os) echo "Dang kiem tra he dieu hanh va trinh quan ly goi..." ;;
            inst_os_valid) echo "He dieu hanh hop le:" ;;
            inst_os_error) echo "He dieu hanh khong duoc ho tro. Cac he dieu hanh ho tro: Arch/CachyOS (Pacman), Ubuntu/Debian (APT), Fedora (DNF)." ;;
            inst_detected_family) echo "Nhom he dieu hanh:" ;;
            inst_detected_pkg_mgr) echo "Trinh quan ly goi duoc su dung:" ;;
            inst_de_warn) echo "Chua phat hien moi truong do hoa (GNOME hoac Hyprland)." ;;
            inst_de_prompt) echo "Ban co muon cai dat GNOME Desktop Environment va GDM khong? [Y/n]: " ;;
            inst_de_installing) echo "Dang cai dat GNOME va GDM..." ;;
            inst_de_done) echo "Da cai dat GNOME va kich hoat GDM (se tu khoi dong khi reboot)." ;;
            inst_de_skip) echo "Bo qua cai dat giao dien Desktop." ;;
            inst_paru_found) echo "Da tim thay 'paru' tren he thong:" ;;
            inst_paru_missing) echo "'paru' chua duoc cai dat. Dang tien hanh cai dat 'paru-bin' tu AUR..." ;;
            inst_paru_deps) echo "Cai dat git va base-devel bang pacman..." ;;
            inst_paru_cloning) echo "Clone repository paru-bin tu nguon chinh thuc AUR vao:" ;;
            inst_paru_success) echo "Cai dat 'paru' thanh cong va da don dep thu muc tam." ;;
            inst_paru_failed) echo "Cai dat 'paru' that bai. Vui long kiem tra lai ket noi mang." ;;
            inst_flatpak_check) echo "Kiem tra va cau hinh Flatpak (tuy chon danh cho cac ung dung Flatpak)..." ;;
            inst_flatpak_installing) echo "Dang cai dat Flatpak..." ;;
            inst_flatpak_remote) echo "Dam bao kho ung dung 'flathub' da duoc them..." ;;
            inst_flatpak_done) echo "Cau hinh Flatpak va kho Flathub hoan tat." ;;
            inst_confirm_title) echo "DANH SACH CAC UNG DUNG SE DUOC TAI & CAI DAT" ;;
            inst_confirm_prompt) echo "Xac nhan tien hanh cai dat? [y/N]: " ;;
            inst_confirm_start) echo "Da xac nhan. Bat dau tien hanh cai dat cac goi..." ;;
            inst_confirm_cancel) echo "Da huy thao tac cai dat theo yeu cau cua nguoi dung." ;;
            inst_clean_cache_prompt) echo "Don dep bo nho cache package de tiet kiem dung luong? [y/N]: " ;;
            inst_clean_cache_cleaning) echo "Dang don dep bo nho cache package..." ;;
            inst_clean_cache_done) echo "Bo nho cache package da duoc don dep." ;;
            inst_clean_cache_keep) echo "Giu lai bo nho cache package." ;;
            inst_setup_prompt) echo "Chay './setup.sh' ngay bay gio de tao lien ket config va bat service? [Y/n]: " ;;
            inst_setup_manual) echo "Ban co the chay './setup.sh' thu cong bat cu luc nao." ;;
            inst_setup_handoff) echo "Chuyen giao sang setup.sh..." ;;
            inst_menu_title) echo "DOTFILES PACKAGES INSTALLER" ;;
            inst_menu_prompt) echo "Vui long chon danh muc ban muon cai dat:" ;;
            inst_opt_all) echo "Cai dat TOAN BO (Manager + Work + Social)" ;;
            inst_opt_manager) echo "Chi cai dat Manager (Nen tang, Trinh duyet, Bo go, Font, Runtime)" ;;
            inst_opt_work) echo "Chi cai dat Work (VS Code, Antigravity, Docker, DBeaver, Unity, LibreSprite...)" ;;
            inst_opt_social) echo "Chi cai dat Social (Vesktop, Cloudflare WARP, Sober Roblox)" ;;
            inst_opt_check) echo "Kiem tra cac goi (Dry run - Xem danh sach, khong cai dat)" ;;
            inst_opt_lang) echo "Doi ngon ngu / Switch language (Hien tai: Tieng Viet)" ;;

            # Setup main menu
            setup_banner) echo "DOTFILES SETUP & CONFIGURATION" ;;
            setup_opt_all) echo "Cai dat toan bo (Tao lien ket configs, theme va services)" ;;
            setup_opt_links) echo "Chi tao lien ket cau hinh (configs/ -> ~/.config/)" ;;
            setup_opt_cursors) echo "Quan ly con tro chuot (cursors)" ;;
            setup_opt_icons) echo "Quan ly bo bieu tuong (icons)" ;;
            setup_opt_wallpapers) echo "Quan ly hinh nen desktop (wallpapers)" ;;
            setup_opt_grub) echo "Quan ly giao dien khoi dong (grub)" ;;
            setup_opt_services) echo "Kich hoat cac services (Docker, WARP)" ;;
            setup_opt_lang) echo "Doi ngon ngu / Switch language (Hien tai: Tieng Viet)" ;;
            setup_done) echo "Thiet lap hoan tat. De ap dung day du bien moi truong va quyen Docker, hay dang xuat hoac khoi dong lai may." ;;

            # Symlink
            link_start) echo "Dang tao lien ket mem (symlinks) tu configs/ sang ~/.config/..." ;;
            link_exists) echo "Da co lien ket hop le tai:" ;;
            link_backup) echo "Phat hien file cu tai dich, da sao luu sang:" ;;
            link_success) echo "Tao lien ket thanh cong:" ;;
            link_failed) echo "Khong the tao lien ket tai:" ;;
            link_total) echo "So muc cau hinh da xu ly:" ;;

            # Cursors
            cursor_banner) echo "QUAN LY CON TRO CHUOT (CURSORS)" ;;
            cursor_opt_1) echo "Oreo Cursors (Mac dinh)" ;;
            cursor_opt_2) echo "Bibata Extra / Rainbow" ;;
            cursor_opt_3) echo "Banana Cursor" ;;
            cursor_preview_opt) echo "Xem truoc hinh anh trong terminal" ;;
            cursor_select_prompt) echo "Chon con tro chuot muon dung [Mac dinh: 1]: " ;;
            cursor_applied) echo "Da ap dung con tro chuot:" ;;

            # Icons
            icon_banner) echo "QUAN LY BO BIEU TUONG (ICONS)" ;;
            icon_opt_1) echo "Candy Icons (Mac dinh)" ;;
            icon_opt_2) echo "Tela Icon Theme" ;;
            icon_opt_3) echo "Fluent Icon Theme" ;;
            icon_preview_opt) echo "Xem truoc hinh anh trong terminal" ;;
            icon_select_prompt) echo "Chon bo bieu tuong muon dung [Mac dinh: 1]: " ;;
            icon_applied) echo "Da ap dung bo bieu tuong:" ;;

            # Wallpapers
            wp_banner) echo "QUAN LY HINH NEN DESKTOP (WALLPAPERS)" ;;
            wp_preview_opt) echo "Bat che do xem truoc tat ca anh" ;;
            wp_select_prompt) echo "Nhap so thu tu anh muon dat lam hinh nen: " ;;
            wp_applied) echo "Da dat hinh nen thanh cong:" ;;

            # GRUB
            grub_banner) echo "QUAN LY GIAO DIEN KHOI DONG (GRUB)" ;;
            grub_warn) echo "Luu y: Chi thuc hien neu may dang dung GRUB Bootloader." ;;
            grub_opt_1) echo "Wintux Dualboot GRUB Theme (Mac dinh)" ;;
            grub_opt_2) echo "Blur GRUB Theme" ;;
            grub_opt_3) echo "Elegant Wave GRUB Theme (Vimix)" ;;
            grub_applied) echo "Cai dat theme GRUB hoan tat." ;;

            # Services
            docker_setup) echo "Dang kiem tra va kich hoat Docker service..." ;;
            docker_done) echo "Docker service da san sang va da them user vao group docker." ;;
            warp_setup) echo "Dang kiem tra va kich hoat Cloudflare WARP service..." ;;
            warp_done) echo "Cloudflare WARP service (warp-svc) da duoc kich hoat." ;;

            # Fallback
            *) echo "$key" ;;
        esac
    else
        # English (Default)
        case "$key" in
            # Common
            info) echo "[INFO]" ;;
            success) echo "[DONE]" ;;
            warning) echo "[WARN]" ;;
            error) echo "[ERROR]" ;;
            back) echo "Back" ;;
            exit) echo "Exit" ;;
            invalid_choice) echo "Invalid selection." ;;
            cancelled) echo "Operation cancelled." ;;
            confirm_prompt) echo "Do you want to proceed? [y/N]: " ;;
            enter_to_continue) echo "Press Enter to continue..." ;;
            select_prompt) echo "Enter your choice: " ;;

            # Installer
            inst_checking_os) echo "Checking operating system and package manager..." ;;
            inst_os_valid) echo "Supported operating system:" ;;
            inst_os_error) echo "Operating system not supported. Supported: Arch/CachyOS (Pacman), Ubuntu/Debian (APT), Fedora (DNF)." ;;
            inst_detected_family) echo "Detected OS Family:" ;;
            inst_detected_pkg_mgr) echo "Active package manager:" ;;
            inst_de_warn) echo "No desktop environment detected (GNOME or Hyprland)." ;;
            inst_de_prompt) echo "Do you want to install GNOME Desktop Environment and GDM? [Y/n]: " ;;
            inst_de_installing) echo "Installing GNOME and GDM..." ;;
            inst_de_done) echo "GNOME installed and GDM enabled (will launch on reboot)." ;;
            inst_de_skip) echo "Skipping desktop environment installation." ;;
            inst_paru_found) echo "Found 'paru' on system:" ;;
            inst_paru_missing) echo "'paru' not found. Bootstrapping 'paru-bin' from AUR..." ;;
            inst_paru_deps) echo "Installing git and base-devel using pacman..." ;;
            inst_paru_cloning) echo "Cloning paru-bin from official AUR to:" ;;
            inst_paru_success) echo "Installed 'paru' successfully and cleaned temporary directory." ;;
            inst_paru_failed) echo "Failed to install 'paru'. Please check your network connection." ;;
            inst_flatpak_check) echo "Checking and configuring Flatpak (optional for Flatpak apps)..." ;;
            inst_flatpak_installing) echo "Installing Flatpak..." ;;
            inst_flatpak_remote) echo "Ensuring 'flathub' remote is added..." ;;
            inst_flatpak_done) echo "Flatpak and Flathub configuration complete." ;;
            inst_confirm_title) echo "PACKAGES TO BE INSTALLED" ;;
            inst_confirm_prompt) echo "Proceed with installation? [y/N]: " ;;
            inst_confirm_start) echo "Confirmed. Starting package installation..." ;;
            inst_confirm_cancel) echo "Installation cancelled by user." ;;
            inst_clean_cache_prompt) echo "Clean package cache to save disk space? [y/N]: " ;;
            inst_clean_cache_cleaning) echo "Cleaning package cache..." ;;
            inst_clean_cache_done) echo "Package cache cleaned." ;;
            inst_clean_cache_keep) echo "Keeping package cache." ;;
            inst_setup_prompt) echo "Run './setup.sh' now to link configs and enable services? [Y/n]: " ;;
            inst_setup_manual) echo "You can run './setup.sh' manually whenever you want." ;;
            inst_setup_handoff) echo "Handing over to setup.sh..." ;;
            inst_menu_title) echo "DOTFILES PACKAGES INSTALLER" ;;
            inst_menu_prompt) echo "Please choose package categories to install:" ;;
            inst_opt_all) echo "Install ALL (Manager + Work + Social)" ;;
            inst_opt_manager) echo "Manager only (Base tools, Browser, Vietnamese input, Fonts, Runtimes)" ;;
            inst_opt_work) echo "Work only (VS Code, Antigravity, Docker, DBeaver, Unity, LibreSprite...)" ;;
            inst_opt_social) echo "Social only (Vesktop, Cloudflare WARP, Sober Roblox)" ;;
            inst_opt_check) echo "Check packages (Dry run - list packages without installing)" ;;
            inst_opt_lang) echo "Switch language / Doi ngon ngu (Current: English)" ;;

            # Setup main menu
            setup_banner) echo "DOTFILES SETUP & CONFIGURATION" ;;
            setup_opt_all) echo "Full setup (Symlink configs, apply theme, enable services)" ;;
            setup_opt_links) echo "Link configs only (configs/ -> ~/.config/)" ;;
            setup_opt_cursors) echo "Manage cursor theme" ;;
            setup_opt_icons) echo "Manage icon theme" ;;
            setup_opt_wallpapers) echo "Manage desktop wallpaper" ;;
            setup_opt_grub) echo "Manage bootloader theme (GRUB)" ;;
            setup_opt_services) echo "Enable system services (Docker, WARP)" ;;
            setup_opt_lang) echo "Switch language (Current: English)" ;;
            setup_done) echo "Setup complete. Please log out or reboot to apply all environment variables and group memberships." ;;

            # Symlink
            link_start) echo "Creating symlinks from configs/ to ~/.config/..." ;;
            link_exists) echo "Valid symlink already exists:" ;;
            link_backup) echo "Existing file found at destination, backed up to:" ;;
            link_success) echo "Linked:" ;;
            link_failed) echo "Failed to link at:" ;;
            link_total) echo "Total configuration items processed:" ;;

            # Cursors
            cursor_banner) echo "CURSOR THEME MANAGER" ;;
            cursor_opt_1) echo "Oreo Cursors (Default)" ;;
            cursor_opt_2) echo "Bibata Extra / Rainbow" ;;
            cursor_opt_3) echo "Banana Cursor" ;;
            cursor_preview_opt) echo "Preview images in terminal" ;;
            cursor_select_prompt) echo "Select cursor to install [Default: 1]: " ;;
            cursor_applied) echo "Applied cursor theme:" ;;

            # Icons
            icon_banner) echo "ICON THEME MANAGER" ;;
            icon_opt_1) echo "Candy Icons (Default)" ;;
            icon_opt_2) echo "Tela Icon Theme" ;;
            icon_opt_3) echo "Fluent Icon Theme" ;;
            icon_preview_opt) echo "Preview images in terminal" ;;
            icon_select_prompt) echo "Select icon theme to install [Default: 1]: " ;;
            icon_applied) echo "Applied icon theme:" ;;

            # Wallpapers
            wp_banner) echo "DESKTOP WALLPAPERS MANAGER" ;;
            wp_preview_opt) echo "Preview all wallpapers" ;;
            wp_select_prompt) echo "Enter the image number to set as desktop wallpaper: " ;;
            wp_applied) echo "Desktop wallpaper applied:" ;;

            # GRUB
            grub_banner) echo "BOOTLOADER (GRUB) THEME MANAGER" ;;
            grub_warn) echo "Note: Run this only if your system uses GRUB Bootloader." ;;
            grub_opt_1) echo "Wintux Dualboot GRUB Theme (Default)" ;;
            grub_opt_2) echo "Blur GRUB Theme" ;;
            grub_opt_3) echo "Elegant Wave GRUB Theme (Vimix)" ;;
            grub_applied) echo "GRUB theme installed successfully." ;;

            # Services
            docker_setup) echo "Checking and enabling Docker service..." ;;
            docker_done) echo "Docker service is active and user added to docker group." ;;
            warp_setup) echo "Checking and enabling Cloudflare WARP service..." ;;
            warp_done) echo "Cloudflare WARP service (warp-svc) is active." ;;

            # Fallback
            *) echo "$key" ;;
        esac
    fi
}
