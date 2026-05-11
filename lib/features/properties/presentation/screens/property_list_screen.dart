import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:space_shift/features/home/presentation/widgets/home_search_unit.dart';

import '../providers/publicaciones_provider.dart';
import '../widgets/property_card.dart';

class PropertyListScreen extends ConsumerWidget {
  const PropertyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicacionesAsync = ref.watch(publicacionesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: ShadTheme.of(context).colorScheme.primary,
        foregroundColor: ShadTheme.of(context).colorScheme.primaryForeground,
        onPressed: () => context.push('/create_publication'),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeSearchUnit(),
                const SizedBox(height: 24),
                publicacionesAsync.when(
                  data: (publicaciones) {
                    if (publicaciones.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Text('No hay publicaciones que coincidan con tu búsqueda'),
                        ),
                      );
                    }

                    final mitad = (publicaciones.length / 2).ceil();
                    final finDeSemana = publicaciones.take(mitad).toList();
                    final moda = publicaciones.skip(mitad).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ofertas para el fin de semana',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ahorra en estancias en estas fechas: 10 de abril - 12 de abril',
                          style: TextStyle(
                            fontSize: 16,
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 380,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: finDeSemana.length,
                            itemBuilder: (context, index) {
                              return PropertyCard(
                                publicacion: finDeSemana[index],
                                onTap: () => context.push('/property_detail', extra: finDeSemana[index]),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Destinos de moda',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Opciones más populares entre la comunidad',
                          style: TextStyle(
                            fontSize: 16,
                            color: ShadTheme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 380,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: moda.isNotEmpty ? moda.length : finDeSemana.length,
                            itemBuilder: (context, index) {
                              final pub = moda.isNotEmpty ? moda[index] : finDeSemana[index];
                              return PropertyCard(
                                publicacion: pub,
                                onTap: () => context.push('/property_detail', extra: pub),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Error al cargar publicaciones',
                            style: TextStyle(color: ShadTheme.of(context).colorScheme.destructive)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
