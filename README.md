# Introduction to Databse Project - SOT - UMT
Dự án môn học Nhập môn Cơ sở dữ liệu thực hiện bởi sinh viên Khoa Công nghệ - Trường Đại học Quản lý và Công nghệ TP.HCM (UMT)

Đồ án với sự đóng góp của 6 thành viên:
- Trần Huỳnh Long - 2403700010 - **LEADER**
- Phạm Đăng Hoàng Thiên - 2403700151
- Nguyễn Phúc Duy - 2403700173
- Hồ Ngọc Vân Anh - 2403700192
- Trần Nguyễn Phương Vy - 2403700319
- Trần Thành Đạt - 2403700251


## Tổng quan dự án
Ứng dụng web cơ bản kết nối cơ sở dữ liệu để quản lý thông tin, được xây dựng trên nền tảng:

Backend: Node.js & Express.js

Frontend: Handlebars (HBS) Template Engine

Database: MySQL (Workbench 8.0)

Kiến trúc: MVC (Model-View-Controller) cơ bản

## Cấu trúc thư mục 
Dựa trên cấu trúc hiện tại của dự án:

Project/

├── app.js                # Server chính và cấu hình route

├── script_sql/           # Chứa các file truy vấn, tạo bảng SQL

├── views/                # Chứa giao diện Handlebars (.handlebars)

│   ├── layouts/          # Giao diện khung (Main layout)

│   └── home.handlebars   # Giao diện trang chủ

├── utils/                # Các hàm tiện ích, cấu hình kết nối DB

├── public/               # (Tùy chọn) Chứa CSS, hình ảnh, JS phía client

└── package.json          # Quản lý thư viện và scripts của Node.js

## Hướng dẫn cho thành viên trong nhóm

### 1. Quy định Commit Code (Bắt buộc)
Để dễ dàng theo dõi ai đã làm gì, mọi người phải tuân thủ cấu trúc commit sau:

Cấu trúc: <type>(scope): [TÊN_VIẾT_TẮT] <mô_tả>

<type>

- feat: Thêm chức năng/giao diện mới.
- fix: Sửa lỗi bug.
- docs: Cập nhật file README này hoặc tài liệu khác.
- style: Chỉnh sửa giao diện, format code (không đổi logic).
- refactor: Tối ưu hóa code cũ.
- chore: Cập nhật cấu hình, thư viện, .gitignore

scope: Phần bạn tác động (ví dụ: db, ui, logic,...).

eg. Nếu tui thêm phần ui cho home & main.

feat(ui): [PDHT] update home and main layout templates

### 2. Quy trình làm việc với Nhánh (Branching)

Tuyệt đối không code trực tiếp trên nhánh main. Mỗi tính năng mới phải làm trên một nhánh riêng
Tạo nhánh mới:

git checkout -b <TÊN_VIẾT_TẮT>
Ví dụ: git checkout -b PDHT

Sau khi hoàn thành code trên nhánh:

git add .
git commit -m "feat(db): [PDHT] hoàn thành script tạo bảng"
git push origin <tên-nhánh-của-bạn>

## Cài đặt môi trường phát triển

- Tải mã nguồn: git clone <link-github-repo>
- Cài đặt thư viện: 
  - npm init -y
  - npm i express
  - npm i express-handlebars
  - npm i express-handlebars-sections
  - npm install knex
  - npm install mysql2
  - npm install bootstrap
  - npm install nodemon
- Cấu hình Database: Chạy các file trong script_sql/ và cập nhật thông tin kết nối trong utils/.
- Chạy ứng dụng: node app.js (hoặc npm start nếu đã cấu hình).

## Ghi chú
Trước khi bắt đầu code, nhớ chạy git pull origin main để lấy code mới nhất về.
