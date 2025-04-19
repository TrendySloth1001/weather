import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/weather_screen.dart';
import 'services/database_helper.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    await SharedPreferences.getInstance();
    await DatabaseHelper.init();
    runApp(const MainApp());
  } catch (e) {
    print('Initialization error: $e');
    // Fallback initialization without SharedPreferences
    runApp(const MainApp());
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: Color(0xFF1E1E1E),
          background: Colors.black,
        ),
      ),
      home: const WeatherScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
