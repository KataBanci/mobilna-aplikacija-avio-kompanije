import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:aviokomopanija/consts/app_colors.dart';
import 'package:aviokomopanija/screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'airvista',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.lightPrimary),
        scaffoldBackgroundColor: AppColors.lightScaffoldColor,
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 10, color: AppColors.lightPrimary),
          ),
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
