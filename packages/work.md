# Packages: Ứng dụng Phục vụ Công việc (Work)

Tài liệu này lưu trữ danh sách các phần mềm phục vụ lập trình, thiết kế tài nguyên game, quản lý cơ sở dữ liệu, chụp màn hình và tác vụ văn phòng.

---

## Pacman / AUR

Các gói này sẽ được cài đặt thông qua `paru` (hoặc `pacman`).

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
- `onlyoffice-bin`: Bộ ứng dụng văn phòng (tài liệu văn bản, bảng tính spreadsheet, trình chiếu slide) có độ tương thích định dạng Microsoft Office (.docx, .xlsx, .pptx) cao nhất trên Linux.
- `flameshot`: Ứng dụng chụp ảnh màn hình tiện lợi, hỗ trợ vẽ hình khối, mũi tên, bôi đen làm mờ thông tin nhạy cảm và copy nhanh vào clipboard.
- `obs-studio`: Phần mềm mã nguồn mở mạnh mẽ để quay video màn hình chất lượng cao và livestream.

### 5. Container & Ảo hóa
- `docker`: Nền tảng container hóa hàng đầu giúp chạy các ứng dụng, database và môi trường cô lập.
- `docker-compose`: Công cụ quản lý và khởi chạy ứng dụng nhiều container thông qua file cấu hình YAML.

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

