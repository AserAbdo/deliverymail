import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/injection_container.dart' as di;
import 'features/splash/presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const KhodargyApp());
}

class KhodargyApp extends StatelessWidget {
  const KhodargyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'خضرجي - متجر الخضار والفواكه',
      debugShowCheckedModeBanner: false,

      // RTL support for Arabic
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG')],

      // Localization delegates for Material, Cupertino, and Widgets
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Fresh green
          brightness: Brightness.light,
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFFFF6F00), // Orange accent
          tertiary: const Color(0xFFE91E63), // Pink for fruits
        ),

        // Beautiful Arabic typography
        textTheme: GoogleFonts.cairoTextTheme(),

        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2E7D32),
          titleTextStyle: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),

        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
