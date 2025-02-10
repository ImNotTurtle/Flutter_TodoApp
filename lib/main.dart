import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/screens/main_screen.dart';
import 'package:window_manager/window_manager.dart';


final ColorScheme customColorScheme = ColorScheme(
  primary: Color(0xFF663399),        // Deep Purple (RebeccaPurple)
  primaryContainer: Color(0xFF4A287A), // Darker shade of primary
  secondary: Color(0xFF53297D),      // Slightly desaturated Deep Purple
  secondaryContainer: Color(0xFF3E2167), // Darker secondary
  surface: Color(0xFF262626),        // Dark surface color
  surfaceContainerHighest: Color(0xFF1A1A1A),     // Dark background color
  error: Color(0xFFFF3333),          // Bright red for error
  onPrimary: Color(0xFFFFFFFF),      // White text on primary
  onSecondary: Color(0xFFFFFFFF),    // White text on secondary
  onSurface: Color(0xFFFFFFFF),      // White text on surface
  // onBackground: Color(0xFFFFFFFF),   // White text on background
  onError: Color(0xFF000000),        // Black text on error
  brightness: Brightness.dark,       // Dark theme
);

final ThemeData customThemeData = ThemeData(
  colorScheme: customColorScheme,
  textTheme: TextTheme(
    headlineLarge: TextStyle(color: customColorScheme.onSurface, fontSize: 28, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: customColorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(color: customColorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(color: customColorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.normal),
    bodySmall: TextStyle(color: customColorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.normal),
    labelLarge: TextStyle(color: customColorScheme.onPrimary, fontSize: 14, fontWeight: FontWeight.bold),
    labelMedium: TextStyle(color: customColorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.normal),
    labelSmall: TextStyle(color: customColorScheme.onSurface, fontSize: 10, fontWeight: FontWeight.normal),
  ),
  scaffoldBackgroundColor: customColorScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: customColorScheme.primary,
    foregroundColor: customColorScheme.onPrimary,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: customColorScheme.primary,
    textTheme: ButtonTextTheme.primary,
  ),
);




void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    title: 'Todo app',
    size: Size(700, 600),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
