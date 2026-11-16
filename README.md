**Language / Ngôn ngữ:** [English](README.md) | [Tiếng Việt](README.vi.md)

---

# My Dotfiles & Linux Setup

A clean and automated dotfiles setup to recreate a development environment across popular Linux distributions:
- **Arch-based**: Arch Linux, CachyOS, EndeavourOS, Manjaro (via `pacman` & `paru` AUR).
- **Debian / Ubuntu-based**: Ubuntu, Debian, Linux Mint, Pop!_OS (via `apt` with automated vendor repository setup).
- **Fedora-based**: Fedora, RHEL, Nobara (via `dnf` with automated RPM repository setup).

Architecture follows separation of concerns:
- **`install.sh`**: Auto-detects your distribution and installs native packages via the corresponding package manager (Pacman, APT, DNF).
- **`setup.sh`**: Links configuration dotfiles to `~/.config/`, sets up default desktop themes, and enables services.
- **`scripts/`**: Individual management scripts matching corresponding `assets/` directories (Cursors, Icons, Wallpapers, GRUB).

---

## Directory Structure

```text
.
├── install.sh                  # Main script to download and install packages
├── setup.sh                    # Central setup and dotfile configuration controller
├── scripts/                    # Modular scripts matching assets/ directories
│   ├── cursors.sh              # Manage cursor themes (assets/cursors)
│   ├── icons.sh                # Manage icon themes (assets/icons)
│   ├── wallpapers.sh           # Preview and apply desktop wallpapers (assets/wallpapers)
│   ├── grub.sh                 # Install and manage bootloader themes (assets/grup_menu)
│   └── lib/                    # Shared libraries (i18n, dotfile generators)
│       ├── i18n.sh             # English (default) and Vietnamese language strings
│       └── theme_apply.sh      # Writes XCursor & GTK3/GTK4 settings.ini dotfiles
├── packages/                   # Categorized software packages in Markdown
│   ├── manager.md              # Base tools, runtimes (Node, uv), fonts, Fcitx5, Brave, rofi, chafa
│   ├── work.md                 # Work: VS Code, Docker, Unity, DBeaver, Postman, Flameshot, OBS...
│   └── social.md               # Social: Vesktop (Discord), Cloudflare WARP, Sober (Roblox)
├── configs/                    # Tracked dotfiles (symlinked to ~/.config/)
│   ├── environment.d/          # User environment variables (systemd user env for Fcitx5)
│   │   └── fcitx5.conf
│   └── autostart/              # Autostart desktop entries (Fcitx5)
│       └── fcitx5.desktop
├── assets/                     # Multimedia assets and preview images
│   ├── cursors/                # Cursor preview images (oreo.png, bibata_extra.png, banana.png)
│   ├── icons/                  # Icon preview images (candy_icons.png, fluent_icons.png, tela_icons.png)
│   ├── grup_menu/              # GRUB preview images (wintux_grub.gif, blur_grub.png, elegant_wave_grub.png)
│   ├── wallpapers/             # Personal wallpaper collection (static images and videos)
│   ├── avatars/                # Account avatar (mahihi.png)
│   └── hyprland/               # Hyprland configs/assets (reserved for future use)
└── notes/                      # Notes (e.g. university wifi setup)
```

---

## How to Use

### Step 1: Clone the repository
```bash
git clone https://github.com/bettercallkhang/my-setup.git ~/my-setup
cd ~/my-setup
```

### Step 2: Install required packages
```bash
chmod +x install.sh setup.sh scripts/*.sh
./install.sh
```
*The script displays a numbered list of packages and requests your confirmation before downloading.*

### Step 3: Link configurations and apply themes
```bash
./setup.sh
```
Or run individual modular scripts directly:
- `./scripts/cursors.sh`: Select and apply cursor theme (Default: Oreo Cursors).
- `./scripts/icons.sh`: Select and apply icon theme (Default: Candy Icons).
- `./scripts/wallpapers.sh`: Preview and set wallpaper using `chafa`.
- `./scripts/grub.sh`: Install GRUB bootloader theme.

### Step 4: Reboot your system
Reboot (or log out) so that all environment variables and user group permissions take effect:
```bash
sudo reboot
```

---

## Important Post-Installation Notes

> [!IMPORTANT]
> **1. Rootless Docker Permissions**:
> After rebooting, your user account is in the `docker` group, allowing you to run `docker ps` and `docker compose` without `sudo`.
>
> **2. Vietnamese Input Setup (Fcitx5)**:
> - After rebooting, open **Fcitx5 Configuration** (or execute `fcitx5-configtool` in a terminal).
> - In the **Input Method** tab, uncheck *Only Show Current Language*, search for and add **Unikey**.
> - The default toggle shortcut is `Ctrl + Space`.
>
> **3. Activate Cloudflare WARP (1.1.1.1 VPN)**:
> The background service `warp-svc` is enabled automatically. To connect for the first time, run:
> ```bash
> warp-cli registration new
> warp-cli connect
> ```
> To check connection status: `warp-cli status`. To disconnect: `warp-cli disconnect`.

---

## References & Credits

### Cursor Themes
- **Oreo Cursors**:
  - Author: Varlesh
  - GitHub: [varlesh/oreo-cursors](https://github.com/varlesh/oreo-cursors)
  - Gnome-Look: [Oreo Cursors on Pling](https://www.pling.com/p/1360254/)
- **Bibata Extra / Rainbow**:
  - Author: Abdulkaiz Khatri (ful1e5)
  - Gnome-Look: [Bibata Extra on Gnome-Look](https://www.gnome-look.org/p/1931412)
  - GitHub: [ful1e5/Bibata_Cursor](https://github.com/ful1e5/Bibata_Cursor)
- **Banana Cursor**:
  - Author: mdomlop
  - Gnome-Look: [Banana Cursor on Gnome-Look](https://www.gnome-look.org/p/1269768)
  - GitHub: [mdomlop/banana-cursor](https://github.com/mdomlop/banana-cursor)

### Icon Themes
- **Candy Icons**:
  - Author: EliverLara
  - GitHub: [EliverLara/candy-icons](https://github.com/EliverLara/candy-icons)
- **Tela Icon Theme**:
  - Author: Vince Liuice
  - Gnome-Look: [Tela Icon Theme on Gnome-Look](https://www.gnome-look.org/p/1279924)
  - GitHub: [vinceliuice/Tela-icon-theme](https://github.com/vinceliuice/Tela-icon-theme)
- **Fluent Icon Theme**:
  - Author: Vince Liuice
  - Gnome-Look: [Fluent Icon Theme on Gnome-Look](https://www.gnome-look.org/p/1477945)
  - GitHub: [vinceliuice/Fluent-icon-theme](https://github.com/vinceliuice/Fluent-icon-theme)

### GRUB Bootloader Themes
- **Wintux Dualboot GRUB Theme**:
  - Author: Harshil Anuwadia
  - GitHub: [Harshil-Anuwadia/wintux-dualboot-grub-theme-updated](https://github.com/Harshil-Anuwadia/wintux-dualboot-grub-theme-updated)
- **Blur GRUB Theme (Tela / CyberEXS)**:
  - Author: Vince Liuice
  - Gnome-Look: [Blur GRUB on Gnome-Look](https://www.gnome-look.org/p/2206122)
  - GitHub: [vinceliuice/grub2-themes](https://github.com/vinceliuice/grub2-themes)
- **Elegant Wave GRUB Theme (Vimix)**:
  - Author: Vince Liuice
  - Gnome-Look: [Vimix GRUB on Gnome-Look](https://www.gnome-look.org/p/1220920)
  - GitHub: [vinceliuice/grub2-themes](https://github.com/vinceliuice/grub2-themes)
