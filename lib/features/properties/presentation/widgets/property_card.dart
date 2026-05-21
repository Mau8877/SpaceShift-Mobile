import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/publicacion.dart';
import '../providers/favoritos_provider.dart';

class PropertyCard extends ConsumerWidget {
  final Publicacion publicacion;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.publicacion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar cambios en la lista de favoritos
    ref.watch(favoritosProvider);
    final isFavorite = ref.read(favoritosProvider.notifier).isFavorito(publicacion.id);
    // Tomamos la primera imagen o un placeholder en línea
    final imageUrl =
        publicacion.imagenesUrls.isNotEmpty
            ? publicacion.imagenesUrls.first
            : 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?q=80&w=400&auto=format&fit=crop';

    final ubicacion = publicacion.inmueble?.ubicacion;
    final locationText = ubicacion != null
        ? '${ubicacion.ciudad}, ${ubicacion.zonaBarrios}'
        : 'Ubicación no disponible';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lBorder),
          // Sutil sombreado
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10), // Opacity 0.04
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Image con borde redondeado arriba
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const SizedBox(height: 140, child: Icon(Icons.image)),
                  ),
                ),
                // Botón favorito "flotante" encima de la imagen
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(favoritosProvider.notifier).toggleFavorito(publicacion);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFavorite ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiqueta Genius estática (por diseño pedido)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.lPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Genius',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Título
                  Text(
                    publicacion.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Ubicación
                  Text(
                    locationText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: ShadTheme.of(context).colorScheme.mutedForeground),
                  ),
                  const SizedBox(height: 12),

                  // Score y comentarios (Mock)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.lPrimary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '8,5',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Muy bien',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '48 comentarios',
                              style: TextStyle(
                                fontSize: 10,
                                color: ShadTheme.of(context).colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sección inferior de precios
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Precio',
                          style: TextStyle(fontSize: 12, color: ShadTheme.of(context).colorScheme.mutedForeground),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${publicacion.moneda} ${publicacion.precio.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
