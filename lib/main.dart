import 'package:flutter/material.dart';
import 'package:flutter_dorm_app/views/dashboard_view.dart';
import 'package:flutter_dorm_app/views/main_layout.dart';
import 'package:flutter_dorm_app/views/splash_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_dorm_app/themes/app_theme.dart'; // 1. เพิ่มการ Import ไฟล์ธีม

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. โหลดไฟล์ .env
  await dotenv.load(fileName: ".env");

  // 2. ดึงค่าจาก .env มาใช้งาน
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    const FlutterDormApp(),
  );
}

//----------------------------------------

class FlutterDormApp extends StatefulWidget {
  const FlutterDormApp({super.key});

  @override
  State<FlutterDormApp> createState() => _FlutterDormAppState();
}

class _FlutterDormAppState extends State<FlutterDormApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainLayout(),
      theme: AppTheme.lightTheme,
    );
  }
}
