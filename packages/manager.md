# Packages: Quản lý hệ thống & Môi trường nền tảng (Manager)

Tài liệu này lưu trữ danh sách các công cụ nền tảng, runtime, trình quản lý gói, font chữ, bộ gõ tiếng Việt và trình duyệt web cần thiết khi cài mới máy Arch Linux hoặc CachyOS.

---

## Pacman / AUR

Các gói này sẽ được cài đặt qua `paru` (AUR Helper) hoặc `pacman`.

### 1. Công cụ biên dịch & Quản lý mã nguồn
- `base-devel`: Nhóm gói chứa gcc, make, fakeroot, autoconf... cần thiết để biên dịch phần mềm từ mã nguồn (bắt buộc để build các gói AUR).
- `git`: Hệ thống quản lý phiên bản mã nguồn, cần để clone repository và các package từ AUR.
- `curl`: Tiện ích dòng lệnh để truyền tải dữ liệu qua các giao thức mạng (HTTP, HTTPS...).
- `wget`: Công cụ tải file qua mạng từ dòng lệnh với khả năng tiếp tục tải khi đứt mạng.

### 2. Trình quản lý gói & Môi trường đóng gói
- `flatpak`: Hệ thống đóng gói và phân phối ứng dụng trong môi trường sandbox cô lập (dùng để cài Sober chơi Roblox).

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

