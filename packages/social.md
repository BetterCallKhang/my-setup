# Packages: Ứng dụng Giải trí & Xã hội (Social)

Tài liệu này lưu trữ danh sách các ứng dụng trò chuyện, VPN mạng và giải trí trò chơi.

---

## Pacman / AUR

Các gói này sẽ được cài đặt thông qua `paru` (hoặc `pacman`) trên Arch Linux và CachyOS.

### 1. Trò chuyện & Cộng đồng
- `vesktop-bin`: Ứng dụng Discord client tùy biến tối ưu nhất cho Linux, sửa lỗi chia sẻ màn hình Wayland và tích hợp sẵn Vencord.

### 2. Mạng & VPN
- `cloudflare-warp-bin`: Client Cloudflare WARP chính thức (VPN 1.1.1.1) giúp mã hóa lưu lượng mạng, tăng tốc độ và bảo mật.

---

## APT (Debian / Ubuntu)

Các gói này sẽ được cài đặt trực tiếp qua `apt` trên Ubuntu, Debian, Linux Mint, Pop!_OS.

### 1. Mạng & VPN
- `cloudflare-warp`: Client Cloudflare WARP chính thức từ kho Cloudflare APT.

*(Ghi chú: `vesktop` sẽ được script tự động tải và cài đặt gói `.deb` bản chính thức từ GitHub releases).*

---

## DNF (Fedora)

Các gói này sẽ được cài đặt trực tiếp qua `dnf` trên Fedora, RHEL, Nobara.

### 1. Mạng & VPN
- `cloudflare-warp`: Client Cloudflare WARP chính thức từ kho Cloudflare DNF.

*(Ghi chú: `vesktop` sẽ được script tự động tải và cài đặt gói `.rpm` bản chính thức từ GitHub releases).*

---

## Flatpak

Các gói này sẽ được cài đặt thông qua `flatpak` từ nguồn `flathub`.

### 1. Trò chơi (Gaming)
- `org.vinegarhq.Sober`: Trình khởi chạy Roblox độc lập tối ưu và mượt mà cho môi trường Linux x86_64.

---

## Hướng dẫn cấu hình sau khi cài đặt (Post-install)

### 1. Thiết lập Cloudflare WARP (VPN 1.1.1.1):
Sau khi cài đặt gói Cloudflare WARP, daemon nền chưa chạy ngay. Cần thực hiện các bước sau:

```bash
# 1. Bật service nền của Cloudflare Warp và cho phép tự khởi động cùng hệ thống:
sudo systemctl enable --now warp-svc

# 2. Đăng ký tài khoản WARP mới (chỉ cần chạy 1 lần duy nhất khi mới cài):
warp-cli registration new

# 3. Kết nối VPN:
warp-cli connect

# 4. Kiểm tra trạng thái kết nối:
warp-cli status

# 5. Khi muốn ngắt kết nối:
warp-cli disconnect
```
*(Script `setup.sh` sẽ tự động bật service nền `warp-svc` cho bạn)*
