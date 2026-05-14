import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lumina/core/utils/debug.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumina/features/home/ui/home_screen.dart';
import 'package:lumina/features/onboarding/ui/onboarding_screen.dart';
import 'package:lumina/core/theme/app_theme.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    dPrint('Error initializing cameras: $e');
  }
  final prefs = await SharedPreferences.getInstance();
  final String savedTheme = prefs.getString('theme_mode') ?? 'light';
  themeNotifier.value = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  final bool isFirstRun = prefs.getBool('is_first_run') ?? true;

  runApp(LuminaApp(isFirstRun: isFirstRun));
}

class LuminaApp extends StatelessWidget {
  final bool isFirstRun;
  const LuminaApp({super.key, required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Lumina',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: isFirstRun ? const OnboardingScreen() : const HomeScreen(),
          routes: {'/home': (context) => const HomeScreen()},
        );
      },
    );
  }
}
