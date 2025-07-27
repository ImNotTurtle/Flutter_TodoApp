import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/app.dart'; // Import widget MyApp dùng chung
import 'package:todo_app/secret.dart';
import 'package:url_strategy/url_strategy.dart';

/// Điểm vào (entry point) cho phiên bản Web.
Future<void> main() async {
  // Đảm bảo Flutter binding đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Cấu hình URL cho web để loại bỏ dấu '#'
  setPathUrlStrategy();

  // Khởi tạo Supabase
  await Supabase.initialize(
    url: kSupaProjectUrl,
    anonKey: kSupaAnnonKey,
    debug: true,
  );

  // Chạy ứng dụng
  runApp(const MyApp());
}
