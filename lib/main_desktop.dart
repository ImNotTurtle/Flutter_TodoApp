import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/app.dart'; // Import widget MyApp dùng chung
import 'package:todo_app/secret.dart';
import 'package:window_manager/window_manager.dart';

/// Điểm vào (entry point) cho phiên bản Desktop.
Future<void> main() async {
  // Đảm bảo Flutter binding đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Cấu hình cửa sổ ứng dụng cho desktop
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    title: 'Todo App',
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Khởi tạo Supabase
  await Supabase.initialize(
    url: kSupaProjectUrl,
    anonKey: kSupaAnnonKey,
    debug: true,
  );

  // Chạy ứng dụng
  runApp(const MyApp());
}
