# Packages: Ứng dụng Phục vụ Công việc (Work)

Tài liệu này lưu trữ danh sách các phần mềm phục vụ lập trình, thiết kế tài nguyên game, quản lý cơ sở dữ liệu, chụp màn hình và tác vụ văn phòng.

---

## Pacman / AUR

Các gói này sẽ được cài đặt thông qua `paru` (hoặc `pacman`) trên Arch Linux và CachyOS.

### 1. Trình soạn thảo & Môi trường phát triển (IDE)
- `visual-studio-code-bin`: Trình soạn thảo mã nguồn Microsoft Visual Studio Code (bản binary chính thức từ Microsoft).
- `antigravity-ide`: Nền tảng phát triển tích hợp dựa trên AI agentic từ Google DeepMind.

### 2. Phát triển Game & Thiết kế Đồ họa
- `unityhub`: Ứng dụng chính thức từ Unity Technologies giúp quản lý các phiên bản Unity Editor, template và project game.
- `libresprite-git`: Công cụ vẽ pixel art và hoạt họa 2D dạng frame-by-frame (bản fork mã nguồn mở miễn phí từ Aseprite).

### 3. Quản trị Cơ sở Dữ liệu & Kiểm thử API
- `dbeaver`: Trình quản trị cơ sở dữ liệu phổ quát miễn phí, hỗ trợ kết nối PostgreSQL, MySQL, SQLite, SQL Server, MongoDB...
- `postman-bin`: Nền tảng API chuyên nghiệp dùng để gửi request HTTP/HTTPS, kiểm thử và tài liệu hóa RESTful API.

### 4. Văn phòng & Công cụ Hỗ trợ
- `onlyoffice-bin`: Bộ ứng dụng văn phòng (tài liệu văn bản, bảng tính spreadsheet, trình chiếu slide) có độ tương thích cao.
- `flameshot`: Ứng dụng chụp ảnh màn hình tiện lợi, hỗ trợ vẽ hình khối, mũi tên, bôi đen làm mờ thông tin.
- `obs-studio`: Phần mềm mã nguồn mở mạnh mẽ để quay video màn hình chất lượng cao và livestream.

### 5. Container & Ảo hóa
- `docker`: Nền tảng container hóa hàng đầu giúp chạy các ứng dụng, database và môi trường cô lập.
- `docker-compose`: Công cụ quản lý và khởi chạy ứng dụng nhiều container thông qua file cấu hình YAML.

---

## APT (Debian / Ubuntu)

Các gói này sẽ được cài đặt trực tiếp qua `apt` trên Ubuntu, Debian, Linux Mint, Pop!_OS.

### 1. Trình soạn thảo & Môi trường phát triển (IDE)
- `code`: Trình soạn thảo Microsoft Visual Studio Code (kho APT chính thức từ Microsoft).

### 2. Quản trị Cơ sở Dữ liệu
- `dbeaver-ce`: Trình quản trị cơ sở dữ liệu phổ quát DBeaver Community Edition.

### 3. Văn phòng & Công cụ Hỗ trợ
- `onlyoffice-desktopeditors`: Bộ ứng dụng văn phòng OnlyOffice Desktop Editors chính thức.
- `flameshot`: Tiện ích chụp ảnh màn hình, chú thích và lưu nhanh.
- `obs-studio`: Phần mềm quay màn hình và phát sóng trực tiếp (livestream).

### 4. Container & Ảo hóa
- `docker.io`: Nền tảng container Docker runtime cho Debian/Ubuntu.
- `docker-compose-v2`: Công cụ quản lý Docker Compose nhiều container.

---

## DNF (Fedora)

Các gói này sẽ được cài đặt trực tiếp qua `dnf` trên Fedora, RHEL, Nobara.

### 1. Trình soạn thảo & Môi trường phát triển (IDE)
- `code`: Trình soạn thảo Microsoft Visual Studio Code (kho DNF chính thức từ Microsoft).

### 2. Quản trị Cơ sở Dữ liệu
- `dbeaver-ce`: Trình quản trị cơ sở dữ liệu phổ quát DBeaver Community Edition.

### 3. Văn phòng & Công cụ Hỗ trợ
- `onlyoffice-desktopeditors`: Bộ ứng dụng văn phòng OnlyOffice Desktop Editors chính thức.
- `flameshot`: Tiện ích chụp ảnh màn hình và chú thích ảnh.
- `obs-studio`: Phần mềm quay màn hình và livestream mã nguồn mở.

### 4. Container & Ảo hóa
- `moby-engine`: Nền tảng container Moby/Docker cho Fedora.
- `docker-compose`: Tiện ích điều phối container Docker Compose.

---

## Flatpak

*(Hiện tại phần Work không có ứng dụng Flatpak)*

---

## Hướng dẫn cấu hình sau khi cài đặt (Post-install)

### Thiết lập Docker:
Sau khi cài Docker, cần bật service nền và phân quyền cho người dùng hiện tại để không phải gõ `sudo` mỗi khi chạy `docker`:

```bash
# 1. Kích hoạt và cho phép Docker tự khởi động cùng máy
sudo systemctl enable --now docker

# 2. Thêm người dùng hiện tại vào nhóm docker (sau đó cần đăng xuất hoặc reboot để có hiệu lực)
sudo usermod -aG docker $USER
```
*(Script `setup.sh` sẽ tự động thực hiện cấu hình này cho bạn)*
