import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/brand_splash_screen.dart';
import 'services/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.restoreSession();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SportyQoApp());
}

class SportyQoApp extends StatelessWidget {
  const SportyQoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportyQo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor:
        const Color(0xFF0A0A1A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF7B2FFF),
          secondary: const Color(0xFF00C853),
          background: const Color(0xFF0A0A1A),
          surface: const Color(0xFF0F0F2A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A1A),
          elevation: 0,
          iconTheme:
          IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B2FFF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(14)),
            textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0F0F2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Colors.white10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Colors.white10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF7B2FFF)),
          ),
          hintStyle: const TextStyle(
              color: Colors.white24),
          labelStyle: const TextStyle(
              color: Colors.white38),
        ),
      ),
      home: const BrandSplashScreen(),
    );
  }
}