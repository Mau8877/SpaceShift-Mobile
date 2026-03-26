import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() => runApp(const SpaceShiftApp());

class SpaceShiftApp extends StatelessWidget {
  const SpaceShiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      debugShowCheckedModeBanner: false,
      title: 'SpaceShift Mobile',
      theme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadColorScheme(
          background: Color(0xFF020617),
          foreground: Color(0xFFF8FAFC),
          card: Color(0xFF020617),
          cardForeground: Color(0xFFF8FAFC),
          popover: Color(0xFF020617),
          popoverForeground: Color(0xFFF8FAFC),
          primary: Color(0xFF38BDF8),
          primaryForeground: Color(0xFF0F172A),
          secondary: Color(0xFF1E293B),
          secondaryForeground: Color(0xFFF8FAFC),
          selection: Color(0xFF38BDF8),
          muted: Color(0xFF1E293B),
          mutedForeground: Color(0xFF94A3B8),
          accent: Color(0xFF1E293B),
          accentForeground: Color(0xFFF8FAFC),
          destructive: Color(0xFFEF4444),
          destructiveForeground: Color(0xFFF8FAFC),
          border: Color(0xFF1E293B),
          input: Color(0xFF1E293B),
          ring: Color(0xFF38BDF8),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'SpaceShift',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Para que resalte en el fondo oscuro
              ),
            ),
            const Text(
              'Hub Inmobiliario & AR',
              style: TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 30),
            ShadButton(
              onPressed: () {
                debugPrint("Iniciando exploración en SpaceShift...");
              },
              child: const Text('Comenzar Exploración'),
            ),
          ],
        ),
      ),
    );
  }
}
