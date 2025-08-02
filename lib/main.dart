import 'package:todo_app/main_desktop.dart' as desktop_app;
import 'package:todo_app/main_web.dart' as web_app;

void main() {
  const String targetPlatform = 'desktop';
  //build: flutter build windows -t lib/main_desktop.dart
  // const String targetPlatform = 'web';
  //build: flutter build web -t lib/main_web.dart
  //deploy: vercel build/web --prod

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
