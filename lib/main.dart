// Import các tệp điểm vào của từng nền tảng với một bí danh (alias)
import 'package:todo_app/main_desktop.dart' as desktop_app;
import 'package:todo_app/main_web.dart' as web_app;

/// Đây là tệp chính bạn sẽ chạy từ IDE.
/// Thay đổi giá trị của biến `targetPlatform` để chuyển đổi giữa các phiên bản.
void main() {
  // const String targetPlatform = 'desktop';
  const String targetPlatform = 'web';

  // Dựa vào giá trị của biến, gọi hàm main tương ứng
  switch (targetPlatform) {
    case 'desktop':
      desktop_app.main();
      break;
    case 'web':
      web_app.main();
      break;
    default:
      // Chạy phiên bản desktop làm mặc định nếu giá trị không hợp lệ
      desktop_app.main();
      break;
  }
}
