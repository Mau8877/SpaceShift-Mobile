import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/publicaciones_provider.dart';
import '../widgets/property_card.dart';

class PropertyListScreen extends ConsumerWidget {
  const PropertyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos los datos desde la API mediante el provider
    final publicacionesAsync = ref.watch(publicacionesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Explorar Propiedades')),
      floatingActionButton: FloatingActionButton(
        // Usamos el color Primario de ShadTheme o el global
        backgroundColor: ShadTheme.of(context).colorScheme.primary,
        foregroundColor: ShadTheme.of(context).colorScheme.primaryForeground,
        onPressed: () {
          context.push('/create_publication');
        },
        child: const Icon(Icons.add),
      ),
      body: publicacionesAsync.when(
        data: (publicaciones) {
          if (publicaciones.isEmpty) {
            return const Center(child: Text('No hay publicaciones disponibles'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 80),
            itemCount: publicaciones.length,
            itemBuilder: (context, index) {
              final pub = publicaciones[index];
              return PropertyCard(
                publicacion: pub,
                onTap: () {
                  context.push('/property_detail', extra: pub);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error al cargar publicaciones', style: TextStyle(color: ShadTheme.of(context).colorScheme.destructive)),
              Text(error.toString()),
              const SizedBox(height: 16),
              ShadButton.outline(
                onPressed: () => ref.invalidate(publicacionesProvider),
                child: const Text('Reintentar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
