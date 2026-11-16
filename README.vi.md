**Ngôn ngữ / Language:** [English](README.md) | [Tiếng Việt](README.vi.md)

---

# My Dotfiles & Thiết lập Môi trường Linux

Kho lưu trữ cá nhân giúp tự động hóa và tái tạo môi trường làm việc khi chuyển đổi hoặc cài đặt mới các bản phân phối Linux họ Arch (CachyOS, Arch Linux).

Dự án tuân thủ kiến trúc phân tách rõ ràng:
- **`install.sh`**: Chuyên trách tải và cài đặt các gói phần mềm (Pacman, AUR qua Paru, Flatpak).
- **`setup.sh`**: Chuyên trách liên kết cấu hình dotfiles bằng Symlink, thiết lập giao diện và kích hoạt các services.
- **`scripts/`**: Các kịch bản chuyên biệt tương ứng từng danh mục trong `assets/` (Cursors, Icons, Wallpapers, GRUB).

---

## Cấu trúc Thư mục

```text
.
├── install.sh                  # Kịch bản tải và cài đặt toàn bộ ứng dụng cần thiết
├── setup.sh                    # Kịch bản menu trung tâm thiết lập cấu hình và giao diện
├── scripts/                    # Các kịch bản cài đặt tương ứng từng thư mục assets/
│   ├── cursors.sh              # Quản lý & chọn con trỏ chuột (assets/cursors)
│   ├── icons.sh                # Quản lý & chọn bộ biểu tượng (assets/icons)
│   ├── wallpapers.sh           # Xem trước & đặt hình nền desktop (assets/wallpapers)
│   ├── grub.sh                 # Cài đặt giao diện khởi động GRUB (assets/grup_menu)
│   └── lib/                    # Thư viện dùng chung (i18n, dotfile generators)
│       ├── i18n.sh             # Hỗ trợ Tiếng Anh (Mặc định) và Tiếng Việt
│       └── theme_apply.sh      # Tự động ghi dotfile cho XCursor & GTK3/GTK4 settings.ini
├── packages/                   # Danh mục các phần mềm phân loại theo file Markdown
│   ├── manager.md              # Nền tảng: base-devel, git, flatpak, Node, uv, Fcitx5, fonts, Brave, rofi, chafa
│   ├── work.md                 # Công việc: VS Code, Docker, Unity, DBeaver, Postman, Flameshot, OBS...
│   └── social.md               # Giải trí: Vesktop (Discord), Cloudflare WARP, Sober (Roblox)
├── configs/                    # Chứa toàn bộ file cấu hình dotfiles (được symlink vào ~/.config/)
│   ├── environment.d/          # Cấu hình biến môi trường người dùng (systemd user env cho Fcitx5)
│   │   └── fcitx5.conf
│   └── autostart/              # Tự khởi động ứng dụng cùng màn hình desktop (Fcitx5 autostart)
│       └── fcitx5.desktop
├── assets/                     # Tài nguyên đa phương tiện và ảnh xem trước
│   ├── cursors/                # Ảnh preview con trỏ chuột (oreo.png, bibata_extra.png, banana.png)
│   ├── icons/                  # Ảnh preview icon (candy_icons.png, fluent_icons.png, tela_icons.png)
│   ├── grup_menu/              # Ảnh preview GRUB (wintux_grub.gif, blur_grub.png, elegant_wave_grub.png)
│   ├── wallpapers/             # Bộ sưu tập hình nền cá nhân (ảnh tĩnh và video)
│   ├── avatars/                # Avatar tài khoản (mahihi.png)
│   └── hyprland/               # Cấu hình / tài nguyên cho Hyprland (dành cho tương lai)
└── notes/                      # Các ghi chú kỹ thuật (vd: sửa wifi trường)
```

---

## Hướng dẫn Sử dụng

### Bước 1: Clone repository về máy
```bash
git clone https://github.com/bettercallkhang/my-setup.git ~/my-setup
cd ~/my-setup
```

### Bước 2: Tải và cài đặt ứng dụng
```bash
chmod +x install.sh setup.sh scripts/*.sh
./install.sh
```
*Script sẽ hiển thị danh sách đánh số chi tiết các ứng dụng và yêu cầu bạn xác nhận (`y/N`) trước khi tải.*

### Bước 3: Cấu hình hệ thống & Tùy biến giao diện
```bash
./setup.sh
```
Hoặc bạn có thể chạy trực tiếp từng kịch bản con trong `scripts/`:
- `./scripts/cursors.sh`: Chọn con trỏ chuột (Mặc định: Oreo Cursors).
- `./scripts/icons.sh`: Chọn bộ biểu tượng (Mặc định: Candy Icons).
- `./scripts/wallpapers.sh`: Duyệt và xem trước hình nền bằng `chafa`.
- `./scripts/grub.sh`: Cài đặt giao diện menu khởi động GRUB.

---

## Nguồn Tham Khảo & Tín Dụng (References & Credits)

### Con trỏ chuột (Cursor Themes)
- **Oreo Cursors**:
  - Tác giả: Varlesh
  - Nguồn GitHub: [varlesh/oreo-cursors](https://github.com/varlesh/oreo-cursors)
  - Gnome-Look: [Oreo Cursors on Pling](https://www.pling.com/p/1360254/)
- **Bibata Extra / Rainbow**:
  - Tác giả: Abdulkaiz Khatri (ful1e5)
  - Gnome-Look: [Bibata Extra on Gnome-Look](https://www.gnome-look.org/p/1931412)
  - Nguồn GitHub: [ful1e5/Bibata_Cursor](https://github.com/ful1e5/Bibata_Cursor)
- **Banana Cursor**:
  - Tác giả: mdomlop
  - Gnome-Look: [Banana Cursor on Gnome-Look](https://www.gnome-look.org/p/1269768)
  - Nguồn GitHub: [mdomlop/banana-cursor](https://github.com/mdomlop/banana-cursor)

### Bộ biểu tượng (Icon Themes)
- **Candy Icons**:
  - Tác giả: EliverLara
  - Nguồn GitHub: [EliverLara/candy-icons](https://github.com/EliverLara/candy-icons)
- **Tela Icon Theme**:
  - Tác giả: Vince Liuice
  - Gnome-Look: [Tela Icon Theme on Gnome-Look](https://www.gnome-look.org/p/1279924)
  - Nguồn GitHub: [vinceliuice/Tela-icon-theme](https://github.com/vinceliuice/Tela-icon-theme)
- **Fluent Icon Theme**:
  - Tác giả: Vince Liuice
  - Gnome-Look: [Fluent Icon Theme on Gnome-Look](https://www.gnome-look.org/p/1477945)
  - Nguồn GitHub: [vinceliuice/Fluent-icon-theme](https://github.com/vinceliuice/Fluent-icon-theme)

### Giao diện khởi động máy (GRUB Themes)
- **Wintux Dualboot GRUB Theme**:
  - Tác giả: Harshil Anuwadia
  - Nguồn GitHub: [Harshil-Anuwadia/wintux-dualboot-grub-theme-updated](https://github.com/Harshil-Anuwadia/wintux-dualboot-grub-theme-updated)
- **Blur GRUB Theme (Tela / CyberEXS)**:
  - Tác giả: Vince Liuice
  - Gnome-Look: [Blur GRUB on Gnome-Look](https://www.gnome-look.org/p/2206122)
  - Nguồn GitHub: [vinceliuice/grub2-themes](https://github.com/vinceliuice/grub2-themes)
- **Elegant Wave GRUB Theme (Vimix)**:
  - Tác giả: Vince Liuice
  - Gnome-Look: [Vimix GRUB on Gnome-Look](https://www.gnome-look.org/p/1220920)
  - Nguồn GitHub: [vinceliuice/grub2-themes](https://github.com/vinceliuice/grub2-themes)

