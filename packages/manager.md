# Packages: Quản lý hệ thống & Môi trường nền tảng (Manager)

Tài liệu này lưu trữ danh sách các công cụ nền tảng, runtime, trình quản lý gói, font chữ, bộ gõ tiếng Việt và trình duyệt web cần thiết khi cài mới máy Linux (Arch/CachyOS, Ubuntu/Debian, Fedora).

---

## Pacman / AUR

Các gói này sẽ được cài đặt qua `paru` (AUR Helper) hoặc `pacman` trên Arch Linux và CachyOS.

### 1. Công cụ biên dịch & Quản lý mã nguồn
- `base-devel`: Nhóm gói chứa gcc, make, fakeroot, autoconf... cần thiết để biên dịch phần mềm từ mã nguồn (bắt buộc để build các gói AUR).
- `git`: Hệ thống quản lý phiên bản mã nguồn, cần để clone repository và các package từ AUR.
- `curl`: Tiện ích dòng lệnh để truyền tải dữ liệu qua các giao thức mạng (HTTP, HTTPS...).
- `wget`: Công cụ tải file qua mạng từ dòng lệnh với khả năng tiếp tục tải khi đứt mạng.

### 2. Trình quản lý gói & Môi trường đóng gói
- `flatpak`: Hệ thống đóng gói và phân phối ứng dụng trong môi trường sandbox cô lập.

### 3. Ngôn ngữ & Runtime
- `nodejs`: Môi trường thực thi JavaScript phía máy chủ (Node.js runtime).
- `npm`: Trình quản lý package mặc định đi kèm Node.js.
- `pnpm`: Trình quản lý thư viện JS siêu tốc, tiết kiệm dung lượng ổ cứng nhờ chia sẻ liên kết cứng (hard-link).
- `uv`: Trình quản lý package và môi trường ảo Python cực nhanh bằng Rust do Astral phát triển (thay thế pip, virtualenv, poetry).

### 4. Bộ gõ Tiếng Việt (Fcitx5)
- `fcitx5`: Khung bộ gõ thế hệ mới cho Linux, nhẹ và tương thích hoàn hảo trên cả Wayland lẫn X11.
- `fcitx5-unikey`: Engine gõ tiếng Việt (Unikey) cho Fcitx5, hỗ trợ kiểu gõ Telex, VNI.
- `fcitx5-configtool`: Giao diện đồ họa để tùy chỉnh phím tắt, thêm bộ gõ cho Fcitx5.
- `fcitx5-gtk`: Module tích hợp bộ gõ cho các ứng dụng viết bằng thư viện GTK (GNOME, Firefox, Brave...).
- `fcitx5-qt`: Module tích hợp bộ gõ cho các ứng dụng viết bằng thư viện Qt (KDE, VLC, OBS...).

### 5. Font chữ (Hỗ trợ tiếng Việt, Code & Emoji)
- `inter-font`: Font chữ hiện đại, rõ nét cho giao diện hệ thống và trình duyệt, hỗ trợ tiếng Việt và tiếng Anh cực chuẩn (không bị lỗi dấu thanh).
- `ttf-jetbrains-mono-nerd`: Font đơn khoảng (monospace) tối ưu cho lập trình viên, tích hợp sẵn toàn bộ biểu tượng icon Nerd Font cho Terminal và Editor.
- `noto-fonts-emoji`: Bộ font hiển thị emoji đầy đủ màu sắc từ Google, tránh bị lỗi ô vuông khi nhắn tin hoặc duyệt web.

### 6. Trình duyệt Web & Tiện ích Desktop
- `brave-bin`: Trình duyệt web Brave dựa trên Chromium, tích hợp sẵn chặn quảng cáo, chặn tracker và bảo vệ quyền riêng tư mặc định.
- `rofi`: Trình khởi chạy ứng dụng (app launcher), chuyển đổi cửa sổ và dmenu thay thế.
- `rofi-emoji`: Plugin hỗ trợ tìm kiếm và chèn emoji nhanh chóng qua giao diện Rofi.
- `chafa`: Công cụ hiển thị hình ảnh trong terminal qua ký tự Unicode ANSI TrueColor hoặc giao diện đồ họa Sixel/Kitty.

---

## APT (Debian / Ubuntu)

Các gói này sẽ được cài đặt trực tiếp qua `apt` trên Ubuntu, Debian, Linux Mint, Pop!_OS.

### 1. Công cụ biên dịch & Quản lý mã nguồn
- `build-essential`: Bộ công cụ biên dịch gcc, g++, make... (tương đương base-devel).
- `git`: Quản lý phiên bản mã nguồn, clone repository.
- `curl`: Tiện ích dòng lệnh truyền tải dữ liệu qua giao thức mạng.
- `wget`: Công cụ tải file qua mạng từ dòng lệnh.

### 2. Ngôn ngữ & Runtime
- `nodejs`: Môi trường thực thi JavaScript Node.js runtime.
- `npm`: Trình quản lý package Node.js.

### 3. Bộ gõ Tiếng Việt (Fcitx5)
- `fcitx5`: Khung bộ gõ tiếng Việt thế hệ mới cho Linux.
- `fcitx5-unikey`: Engine gõ tiếng Việt (Unikey) cho Fcitx5.
- `fcitx5-config-qt`: Giao diện cấu hình bộ gõ Fcitx5.
- `fcitx5-frontend-gtk3`: Module tích hợp cho ứng dụng nền tảng GTK3.
- `fcitx5-frontend-gtk4`: Module tích hợp cho ứng dụng nền tảng GTK4.
- `fcitx5-frontend-qt5`: Module tích hợp cho ứng dụng nền tảng Qt5.

### 4. Font chữ (Hỗ trợ tiếng Việt & Emoji)
- `fonts-inter`: Phông chữ Inter sắc nét cho giao diện hệ thống và trình duyệt.
- `fonts-noto-color-emoji`: Bộ phông chữ màu hiển thị emoji từ Google.

### 5. Trình duyệt Web & Tiện ích Desktop
- `brave-browser`: Trình duyệt web Brave chặn quảng cáo và tracker mặc định.
- `rofi`: Trình khởi chạy ứng dụng (app launcher).
- `chafa`: Công cụ xem hình ảnh nhanh trong Terminal.

*(Ghi chú: `uv`, `pnpm` và `JetBrains Mono Nerd Font` sẽ được script tự động tải và cài đặt bản chính thức).*

---

## DNF (Fedora)

Các gói này sẽ được cài đặt trực tiếp qua `dnf` trên Fedora, RHEL, Nobara.

### 1. Công cụ biên dịch & Quản lý mã nguồn
- `git`: Quản lý phiên bản mã nguồn.
- `curl`: Tiện ích truyền tải mạng.
- `wget`: Tiện ích tải file qua mạng.

### 2. Ngôn ngữ & Runtime
- `nodejs`: Môi trường thực thi JavaScript Node.js.
- `npm`: Trình quản lý package Node.js.

### 3. Bộ gõ Tiếng Việt (Fcitx5)
- `fcitx5`: Khung bộ gõ thế hệ mới cho Linux.
- `fcitx5-unikey`: Engine gõ tiếng Việt Unikey cho Fcitx5.
- `fcitx5-configtool`: Giao diện cấu hình bộ gõ Fcitx5.
- `fcitx5-gtk`: Module tích hợp bộ gõ cho GTK.
- `fcitx5-qt`: Module tích hợp bộ gõ cho Qt.

### 4. Font chữ (Hỗ trợ tiếng Việt & Emoji)
- `inter-fonts`: Phông chữ Inter hiển thị rõ nét trên giao diện desktop.
- `google-noto-emoji-color-fonts`: Phông chữ emoji đầy đủ màu sắc từ Google.

### 5. Trình duyệt Web & Tiện ích Desktop
- `brave-browser`: Trình duyệt web Brave chặn quảng cáo mặc định.
- `rofi`: Trình khởi chạy ứng dụng (app launcher).
- `chafa`: Công cụ hiển thị ảnh trong terminal.

*(Ghi chú: `uv`, `pnpm` và `JetBrains Mono Nerd Font` sẽ được script tự động tải và cài đặt bản chính thức).*

---

## Flatpak

*(Hiện tại phần Manager chưa cần cài đặt thêm ứng dụng Flatpak nào)*

---

## Hướng dẫn cấu hình sau khi cài đặt (Post-install)

### Cấu hình biến môi trường cho Fcitx5:
Để Fcitx5 nhận diện và gõ được tiếng Việt trong tất cả ứng dụng, cần thiết lập các biến môi trường sau trong `/etc/environment` hoặc `~/.config/environment.d/fcitx5.conf`:

```bash
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```
*(Script `setup.sh` sẽ tự động cấu hình phần này cho bạn)*
