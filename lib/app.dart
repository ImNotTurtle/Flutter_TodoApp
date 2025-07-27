import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/screens/todo_screen.dart';

/// Widget MyApp dùng chung cho cả hai nền tảng.
/// Nó được đặt trong một tệp riêng để tránh lặp lại code.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,

        // Theme cho chế độ sáng
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          brightness: Brightness.light,
        ),

        // Theme cho chế độ tối
        darkTheme: ThemeData(
          primarySwatch: Colors.indigo,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),

        // Tự động chọn theme dựa trên cài đặt hệ thống
        themeMode: ThemeMode.system,

        // Màn hình chính của ứng dụng
        home: const TodoScreen(),
      ),
    );
  }
}
