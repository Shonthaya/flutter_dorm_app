import 'package:flutter/material.dart';
// import 'package:flutter_dorm_app/screen/splach_screen_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Import flutter_dotenv

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. โหลดไฟล์ .env ก่อนเรียกใช้ Supabase
  await dotenv.load(fileName: ".env");

  // 3. ดึงค่าจาก .env มาใช้งาน
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
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
      //home: const SplachScreenUi(),
      theme: ThemeData(
        textTheme: GoogleFonts.promptTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}
