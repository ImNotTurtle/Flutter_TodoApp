import 'package:flutter/material.dart';
import 'package:todo_app/app.dart';
import 'package:todo_app/secret.dart';
import 'package:todo_app/services/supabase_service.dart';



/// Điểm vào (entry point) cho phiên bản Web.
Future<void> main() async {
  // Đảm bảo Flutter binding đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  

  // Khởi tạo Supabase
  await SupabaseService.instance.init(url: kSupaProjectUrl, anonKey: kSupaAnnonKey);

  // Chạy ứng dụng
  runApp(const MyApp());
}
