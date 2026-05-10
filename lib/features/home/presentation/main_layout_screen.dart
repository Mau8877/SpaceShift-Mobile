import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:space_shift/core/theme/app_theme.dart';
import 'package:space_shift/features/properties/presentation/screens/property_list_screen.dart'
    show PropertyListScreen;

import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/theme_provider.dart';
// Importa aquí otras pantallas que vayas a usar en las pestañas
// import '../../../profile/presentation/screens/profile_screen.dart';
import '../../chat/presentation/screens/bandeja_entrada_screen.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).checkInitialMessage();
    });
  }

  // Índice para controlar qué pestaña está activa
  int _currentIndex = 0;

  // Lista de las pantallas que irán en cada pestaña
  final List<Widget> _screens = [
    const PropertyListScreen(), // Tu catálogo (Índice 0, el default)
    const BandejaEntradaScreen(), // Mensajes/Chats (Índice 1)
    const Center(child: Text('Pantalla de Favoritos')), // Índice 2
    const Center(child: Text('Pantalla de Perfil')), // Índice 3
  ];

  @override
  Widget build(BuildContext context) {
    // Leemos el tema actual para saber qué icono mostrar en el AppBar
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpaceShift'),
        actions: [
          // Botón para cambiar el tema
          ShadButton.ghost(
            child: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              // Alternamos el estado del tema
              ref.read(themeProvider.notifier).state = isDark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        ],
      ),

      // IndexedStack mantiene vivas las pantallas en memoria.
      // Si haces scroll en las casas y vas al perfil, al volver el scroll sigue ahí.
      body: IndexedStack(index: _currentIndex, children: _screens),

      // Usamos el NavigationBar nativo de Material 3 que es súper elegante
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppColors.lPrimary),
            selectedIcon: Icon(Icons.home, color: AppColors.lPrimary),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline, color: AppColors.lPrimary),
            selectedIcon: Icon(Icons.chat_bubble, color: AppColors.lPrimary),
            label: 'Mensajes',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline, color: AppColors.lPrimary),
            selectedIcon: Icon(Icons.favorite, color: AppColors.lPrimary),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: AppColors.lPrimary),
            selectedIcon: Icon(Icons.person, color: AppColors.lPrimary),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
