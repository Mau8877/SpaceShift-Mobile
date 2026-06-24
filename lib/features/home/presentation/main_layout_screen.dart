import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:space_shift/core/theme/app_theme.dart';
import 'package:space_shift/features/properties/presentation/screens/property_list_screen.dart'
    show PropertyListScreen;

import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/theme_provider.dart';
// Importa aquí otras pantallas que vayas a usar en las pestañas
import '../../profile/presentation/screens/profile_screen.dart';
import '../../chat/presentation/screens/bandeja_entrada_screen.dart';
import '../../properties/presentation/screens/favoritos_screen.dart';
import '../../tokens/presentation/providers/tokens_controller.dart';
import '../../videos/presentation/providers/video_upload_controller.dart';

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

  final List<Widget> _screens = [
    const PropertyListScreen(),
    const BandejaEntradaScreen(),
    const FavoritosScreen(),
    const Center(child: Text('Pantalla de Perfil')),
    const ProfileScreen(),
  ];

  void _onTabSelected(int index) {
    if (index == 3) {
      context.push('/profile');
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Leemos el tema actual para saber qué icono mostrar en el AppBar
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpaceShift'),
        actions: [
          // Mostrar los créditos al lado del botón de cambio de tema
          _buildCreditsPill(context, ref),
          const SizedBox(width: 8),
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
          const SizedBox(width: 8),
        ],
      ),

      // IndexedStack mantiene vivas las pantallas en memoria.
      // Si haces scroll en las casas y vas al perfil, al volver el scroll sigue ahí.
      body: Column(
        children: [
          _buildUploadProgressBanner(context, ref),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),

      // Usamos el NavigationBar nativo de Material 3 que es súper elegante
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,

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

  Widget _buildCreditsPill(BuildContext context, WidgetRef ref) {
    final saldoAsync = ref.watch(saldoControllerProvider);
    final theme = ShadTheme.of(context);

    return InkWell(
      onTap: () => context.push('/buy-credits'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.token,
              color: theme.colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 6),
            saldoAsync.when(
              data: (saldo) => Text(
                '${saldo?.saldoCreditos ?? 0} SST',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.colorScheme.primary,
                ),
              ),
              loading: () => const SizedBox(
                height: 10,
                width: 10,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => Text(
                '0 SST',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgressBanner(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(videoUploadControllerProvider);
    
    if (!uploadState.isUploading && !uploadState.completed && uploadState.error == null) {
      return const SizedBox.shrink();
    }
    
    if (uploadState.completed) {
      return Container(
        color: Colors.green.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Expanded(child: Text('Video subido correctamente. Procesando en el servidor...')),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => ref.read(videoUploadControllerProvider.notifier).reset(),
            )
          ],
        ),
      );
    }
    
    if (uploadState.error != null) {
      return Container(
        color: Colors.red.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text('Error al subir: ${uploadState.error}')),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => ref.read(videoUploadControllerProvider.notifier).reset(),
            )
          ],
        ),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_upload, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Subiendo video y preparando modelo 3D...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text('${(uploadState.progress * 100).toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: uploadState.progress),
        ],
      ),
    );
  }
}
