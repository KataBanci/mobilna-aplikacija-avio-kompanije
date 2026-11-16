import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:aviokomopanija/consts/app_colors.dart';
import 'package:aviokomopanija/screens/welcome_screen.dart';
import 'package:aviokomopanija/screens/cities_screen.dart';

import 'services/local_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await LocalDatabase.initialize();
  } catch (_) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Lokalni podaci nisu mogli da se učitaju. Ponovite učitavanje aplikacije. Postojeći podaci nisu prepisani.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: main,
                    child: const Text('Pokušaj ponovo'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AirVista',
      builder: (context, child) => ValueListenableBuilder<String?>(
        valueListenable: LocalDatabase.error,
        builder: (context, error, _) => Column(
          children: [
            Expanded(child: child!),
            if (error != null)
              Material(
                color: const Color(0xFFFFE5DF),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(child: Text(error)),
                        TextButton(
                          onPressed: LocalDatabase.save,
                          child: const Text('Pokušaj ponovo'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      locale: const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
      supportedLocales: const [
        Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF244638),
          primary: const Color(0xFF244638),
        ),
        appBarTheme: const AppBarTheme(
          toolbarHeight: 52,
          backgroundColor: AppColors.lightScaffoldColor,
          surfaceTintColor: Colors.transparent,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF244638),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFAFAF8),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE3E7E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE3E7E0)),
          ),
        ),
        scaffoldBackgroundColor: AppColors.lightScaffoldColor,
        navigationBarTheme: NavigationBarThemeData(
          height: 66,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: const Color(0xFFEDF3EC),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 10, color: AppColors.lightPrimary),
          ),
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      routes: {'/destinations': (_) => const CitiesScreen()},
    );
  }
}
