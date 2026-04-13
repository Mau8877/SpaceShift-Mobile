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

          // Dividimos las publicaciones en dos listas si hubiera muchas para simular la vista pedida
          final mitad = (publicaciones.length / 2).ceil();
          final finDeSemana = publicaciones.take(mitad).toList();
          final moda = publicaciones.skip(mitad).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Sección 1: Ofertas para el fin de semana ---
                  const Text(
                    'Ofertas para el fin de semana',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
                  
                  // Carrusel Horizontal 1
                  SizedBox(
                    height: 380, // Altura ajustada para la tarjeta
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: finDeSemana.length,
                      itemBuilder: (context, index) {
                        return PropertyCard(
                          publicacion: finDeSemana[index],
                          onTap: () {
                            // Envia el ID O el objeto. Elegimos enviar algo en la ruta, por ejemplo un estado extra.
                            context.push('/property_detail', extra: finDeSemana[index]);
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- Sección 2: Destinos de moda ---
                  const Text(
                    'Destinos de moda',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
                  
                  // Carrusel Horizontal 2
                  SizedBox(
                    height: 380,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      // Si la segunda lista esta vacia (por ejemplo solo hay 1 item devuelto total), mostramos los mismos por diseño:
                      itemCount: moda.isNotEmpty ? moda.length : finDeSemana.length,
                      itemBuilder: (context, index) {
                        final pub = moda.isNotEmpty ? moda[index] : finDeSemana[index];
                        return PropertyCard(
                          publicacion: pub,
                          onTap: () {
                            context.push('/property_detail', extra: pub);
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 60), // Margen inferior por el FAB
                ],
              ),
            ),
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
