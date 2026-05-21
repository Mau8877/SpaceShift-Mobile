import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/favoritos_provider.dart';
import '../widgets/property_card.dart';

class FavoritosScreen extends ConsumerWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritosAsync = ref.watch(favoritosProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mis Favoritos',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tus lugares guardados para futuras escapadas.',
                style: TextStyle(
                  fontSize: 16,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: favoritosAsync.when(
                  data: (publicaciones) {
                    if (publicaciones.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aún no tienes propiedades en favoritos.',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.45, // Ajusta la proporción ancho/alto de las cards
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: publicaciones.length,
                      itemBuilder: (context, index) {
                        final pub = publicaciones[index];
                        return PropertyCard(
                          publicacion: pub,
                          onTap: () => context.push('/property_detail', extra: pub),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error al cargar favoritos',
                          style: TextStyle(color: ShadTheme.of(context).colorScheme.destructive),
                        ),
                        const SizedBox(height: 16),
                        ShadButton.outline(
                          onPressed: () => ref.invalidate(favoritosProvider),
                          child: const Text('Reintentar'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
