import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart'; // Importamos el proveedor

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);

    // Escuchamos el tema actual en tiempo real
    final currentTheme = ref.watch(themeProvider);

    return ShadApp.router(
      title: 'SpaceShift Movil',
      debugShowCheckedModeBanner: false,

      themeMode: currentTheme, // ¡Inyectamos el tema dinámico aquí!
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      routerConfig: appRouter,
    );
  }
}
