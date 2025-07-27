
#!/bin/bash

# Gỡ bỏ phiên bản Flutter cũ nếu có để đảm bảo môi trường sạch
rm -rf flutter

# Tải phiên bản Flutter ổn định (stable) mới nhất
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Chạy Flutter doctor để kiểm tra và tải các dependency cần thiết
flutter doctor

# Bật tính năng web nếu chưa được bật
flutter config --enable-web

# Build ứng dụng web với trình kết xuất canvaskit
# và chỉ định tệp điểm vào là main_web.dart
flutter build web --release --web-renderer canvaskit -t lib/main_web.dart
