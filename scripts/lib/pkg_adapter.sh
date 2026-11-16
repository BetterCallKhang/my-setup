#!/usr/bin/env bash

# ==============================================================================
# File: scripts/lib/pkg_adapter.sh
# Purpose: Multi-distribution package manager adapter (Pacman/Paru, APT, DNF)
# ==============================================================================

DETECTED_OS_ID=""
DETECTED_OS_NAME=""
DETECTED_FAMILY=""   # arch | debian | fedora
DETECTED_PKG_MGR=""  # pacman | apt | dnf

COLOR_RESET="\033[0m"
COLOR_GREEN="\033[1;32m"
COLOR_BLUE="\033[1;34m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[1;31m"
COLOR_CYAN="\033[1;36m"

detect_system() {
    if [ -n "${DOTFILES_FORCE_PKG_MGR:-}" ]; then
        DETECTED_PKG_MGR="$DOTFILES_FORCE_PKG_MGR"
        DETECTED_FAMILY="${DOTFILES_FORCE_FAMILY:-$DOTFILES_FORCE_PKG_MGR}"
        DETECTED_OS_ID="${DOTFILES_FORCE_OS_ID:-custom}"
        DETECTED_OS_NAME="${DOTFILES_FORCE_OS_NAME:-Custom Linux}"
        return 0
    fi

    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        DETECTED_OS_ID="${ID:-unknown}"
        DETECTED_OS_NAME="${PRETTY_NAME:-Linux}"
        local id_like="${ID_LIKE:-}"

        if [[ "$DETECTED_OS_ID" == "arch" || "$DETECTED_OS_ID" == "cachyos" || "$DETECTED_OS_ID" == "manjaro" || "$DETECTED_OS_ID" == "endeavouros" || "$id_like" == *"arch"* ]]; then
            DETECTED_FAMILY="arch"
            DETECTED_PKG_MGR="pacman"
        elif [[ "$DETECTED_OS_ID" =~ ^(ubuntu|debian|linuxmint|pop|elementary|zorin|kali)$ || "$id_like" == *"debian"* || "$id_like" == *"ubuntu"* ]]; then
            DETECTED_FAMILY="debian"
            DETECTED_PKG_MGR="apt"
        elif [[ "$DETECTED_OS_ID" =~ ^(fedora|rhel|centos|almalinux|rocky|nobara)$ || "$id_like" == *"fedora"* || "$id_like" == *"rhel"* ]]; then
            DETECTED_FAMILY="fedora"
            DETECTED_PKG_MGR="dnf"
        else
            if command -v pacman &>/dev/null; then
                DETECTED_FAMILY="arch"
                DETECTED_PKG_MGR="pacman"
            elif command -v apt-get &>/dev/null; then
                DETECTED_FAMILY="debian"
                DETECTED_PKG_MGR="apt"
            elif command -v dnf &>/dev/null; then
                DETECTED_FAMILY="fedora"
                DETECTED_PKG_MGR="dnf"
            else
                return 1
            fi
        fi
        return 0
    fi
    return 1
}

# ------------------------------------------------------------------------------
# Arch Linux: Paru bootstrap
# ------------------------------------------------------------------------------
bootstrap_arch_paru() {
    if command -v paru &> /dev/null; then
        echo -e "${COLOR_GREEN}$(t info)${COLOR_RESET} $(t inst_paru_found) $(command -v paru)"
        return 0
    fi

    echo -e "${COLOR_YELLOW}$(t warning)${COLOR_RESET} $(t inst_paru_missing)"
    echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} $(t inst_paru_deps)"
    sudo pacman -S --needed --noconfirm base-devel git

    local tmp_paru
    tmp_paru="$(mktemp -d /tmp/paru-bootstrap.XXXXXX)"
    echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} $(t inst_paru_cloning) $tmp_paru"
    git clone https://aur.archlinux.org/paru-bin.git "$tmp_paru"
    (
        cd "$tmp_paru" || exit 1
        makepkg -si --noconfirm
    )
    rm -rf "$tmp_paru"

    if command -v paru &> /dev/null; then
        echo -e "${COLOR_GREEN}$(t success)${COLOR_RESET} $(t inst_paru_success)"
    else
        echo -e "${COLOR_RED}$(t error)${COLOR_RESET} $(t inst_paru_failed)"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Debian / Ubuntu: Third-party repository bootstrap
# ------------------------------------------------------------------------------
setup_debian_repos() {
    echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} Configuring third-party APT repositories (Brave, VS Code, Cloudflare, DBeaver, OnlyOffice)..."
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends curl wget gnupg ca-certificates apt-transport-https lsb-release build-essential git

    local codename
    codename="$(lsb_release -cs 2>/dev/null || echo "jammy")"

    # 1. Brave Browser
    if [ ! -f /etc/apt/sources.list.d/brave-browser-release.list ]; then
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg 2>/dev/null || true
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null
    fi

    # 2. Microsoft Visual Studio Code
    if [ ! -f /etc/apt/sources.list.d/vscode.list ]; then
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor 2>/dev/null | sudo tee /usr/share/keyrings/packages.microsoft.gpg >/dev/null || true
        echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
    fi

    # 3. Cloudflare WARP
    if [ ! -f /etc/apt/sources.list.d/cloudflare-client.list ]; then
        curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg 2>/dev/null || true
        echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $codename main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list >/dev/null
    fi

    # 4. DBeaver CE
    if [ ! -f /etc/apt/sources.list.d/dbeaver.list ]; then
        curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/dbeaver.gpg 2>/dev/null || true
        echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list >/dev/null
    fi

    # 5. OnlyOffice
    if [ ! -f /etc/apt/sources.list.d/onlyoffice.list ]; then
        mkdir -p -m 700 "$HOME/.gnupg"
        curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --import 2>/dev/null || true
        if [ -f /tmp/onlyoffice.gpg ]; then
            sudo chmod 644 /tmp/onlyoffice.gpg
            sudo chown root:root /tmp/onlyoffice.gpg
            sudo mv /tmp/onlyoffice.gpg /usr/share/keyrings/onlyoffice.gpg
            echo "deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main" | sudo tee /etc/apt/sources.list.d/onlyoffice.list >/dev/null
        fi
    fi

    # Refresh index after adding repos
    sudo apt-get update -y
}

# ------------------------------------------------------------------------------
# Fedora: Third-party repository bootstrap
# ------------------------------------------------------------------------------
setup_fedora_repos() {
    echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} Configuring third-party DNF repositories (Brave, VS Code, Cloudflare, DBeaver, OnlyOffice)..."
    sudo dnf install -y git curl wget

    # 1. Brave Browser
    if [ ! -f /etc/yum.repos.d/brave-browser.repo ]; then
        sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo 2>/dev/null || true
    fi

    # 2. Microsoft Visual Studio Code
    if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>/dev/null || true
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    fi

    # 3. Cloudflare WARP
    if [ ! -f /etc/yum.repos.d/cloudflare-warp-ascii.repo ]; then
        sudo rpm --import https://pkg.cloudflareclient.com/pubkey.gpg 2>/dev/null || true
        sudo dnf config-manager --add-repo https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo 2>/dev/null || true
    fi

    # 4. DBeaver CE
    if [ ! -f /etc/yum.repos.d/dbeaver.repo ]; then
        sudo rpm --import https://dbeaver.io/debs/dbeaver.gpg.key 2>/dev/null || true
        sudo sh -c 'echo -e "[dbeaver-ce]\nname=DBeaver CE\nbaseurl=https://dbeaver.io/debs/dbeaver-ce\nenabled=1\ngpgcheck=1\ngpgkey=https://dbeaver.io/debs/dbeaver.gpg.key" > /etc/yum.repos.d/dbeaver.repo'
    fi

    # 5. OnlyOffice
    if [ ! -f /etc/yum.repos.d/onlyoffice.repo ]; then
        sudo rpm --import https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE 2>/dev/null || true
        sudo sh -c 'echo -e "[onlyoffice]\nname=onlyoffice repo\nbaseurl=https://download.onlyoffice.com/repo/centos/main/noarch/\ngpgcheck=1\nenabled=1" > /etc/yum.repos.d/onlyoffice.repo'
    fi
}

# ------------------------------------------------------------------------------
# Dispatcher: Bootstrap environment for detected OS
# ------------------------------------------------------------------------------
bootstrap_environment() {
    case "$DETECTED_FAMILY" in
        arch)
            bootstrap_arch_paru
            ;;
        debian)
            setup_debian_repos
            ;;
        fedora)
            setup_fedora_repos
            ;;
        *)
            echo -e "${COLOR_RED}$(t error)${COLOR_RESET} Unsupported OS family: $DETECTED_FAMILY"
            return 1
            ;;
    esac
}

# ------------------------------------------------------------------------------
# Native Package Batch Installer
# ------------------------------------------------------------------------------
install_native_packages() {
    local pkgs=("$@")
    [ ${#pkgs[@]} -eq 0 ] && return 0

    case "$DETECTED_FAMILY" in
        arch)
            paru -S --needed --noconfirm "${pkgs[@]}"
            ;;
        debian)
            sudo apt-get install -y --no-install-recommends "${pkgs[@]}"
            ;;
        fedora)
            sudo dnf install -y "${pkgs[@]}"
            ;;
    esac
}

# ------------------------------------------------------------------------------
# Post-install helpers for tools distributed outside standard repos
# ------------------------------------------------------------------------------
post_install_helpers() {
    local category="$1"

    # Category: Manager (uv, pnpm, JetBrains Nerd Font)
    if [ "$category" == "Manager" ]; then
        # uv (Astral Python)
        if ! command -v uv &> /dev/null; then
            echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} Installing 'uv' via official installer..."
            curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null || true
        fi

        # pnpm
        if ! command -v pnpm &> /dev/null && command -v npm &> /dev/null; then
            echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} Installing 'pnpm' via npm..."
            sudo npm install -g pnpm 2>/dev/null || true
        fi

        # JetBrains Mono Nerd Font (for Debian/Fedora where repo may lack full nerd icons)
        if [ "$DETECTED_FAMILY" != "arch" ]; then
            local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerd"
            if [ ! -d "$font_dir" ]; then
                echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} Downloading JetBrains Mono Nerd Font..."
                mkdir -p "$font_dir"
                local tmp_font
                tmp_font="$(mktemp -d /tmp/nerd-font.XXXXXX)"
                if curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" -o "$tmp_font/JetBrainsMono.tar.xz" 2>/dev/null; then
                    tar -xf "$tmp_font/JetBrainsMono.tar.xz" -C "$font_dir" 2>/dev/null || true
                    fc-cache -f "$font_dir" 2>/dev/null || true
                fi
                rm -rf "$tmp_font"
            fi
        fi
    fi

    # Category: Social (Vesktop native installer on Debian/Ubuntu and Fedora)
    if [ "$category" == "Social" ]; then
        if ! command -v vesktop &> /dev/null; then
            echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} Checking native Vesktop package for $DETECTED_FAMILY..."
            local tmp_vesktop
            tmp_vesktop="$(mktemp -d /tmp/vesktop-dl.XXXXXX)"

            if [ "$DETECTED_FAMILY" == "debian" ]; then
                local deb_url
                deb_url="$(curl -fsSL https://api.github.com/repos/Vencord/Vesktop/releases/latest 2>/dev/null | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4 | head -n 1)"
                if [ -n "$deb_url" ]; then
                    echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} Downloading Vesktop .deb package..."
                    curl -fsSL "$deb_url" -o "$tmp_vesktop/vesktop.deb"
                    sudo apt-get install -y "$tmp_vesktop/vesktop.deb" 2>/dev/null || true
                fi
            elif [ "$DETECTED_FAMILY" == "fedora" ]; then
                local rpm_url
                rpm_url="$(curl -fsSL https://api.github.com/repos/Vencord/Vesktop/releases/latest 2>/dev/null | grep "browser_download_url.*x86_64.rpm" | cut -d '"' -f 4 | head -n 1)"
                if [ -n "$rpm_url" ]; then
                    echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} Downloading Vesktop .rpm package..."
                    curl -fsSL "$rpm_url" -o "$tmp_vesktop/vesktop.rpm"
                    sudo dnf install -y "$tmp_vesktop/vesktop.rpm" 2>/dev/null || true
                fi
            fi
            rm -rf "$tmp_vesktop"
        fi
    fi
}

# ------------------------------------------------------------------------------
# Clean Package Cache
# ------------------------------------------------------------------------------
clean_system_cache() {
    case "$DETECTED_FAMILY" in
        arch)
            if command -v paru &> /dev/null; then
                paru -Sc --noconfirm
            fi
            ;;
        debian)
            sudo apt-get clean
            ;;
        fedora)
            sudo dnf clean all
            ;;
    esac
}