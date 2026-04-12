import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../domain/publicacion.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Publicacion publicacion;

  const PropertyDetailScreen({
    super.key,
    required this.publicacion,
  });

  @override
  Widget build(BuildContext context) {
    final inmueble = publicacion.inmueble;
    final ubicacion = inmueble?.ubicacion;
    
    final imageUrl =
        publicacion.imagenesUrls.isNotEmpty
            ? publicacion.imagenesUrls.first
            : 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?q=80&w=600&auto=format&fit=crop';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Propiedad'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gran Imagen Central
            Image.network(
              imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    publicacion.titulo,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  if (ubicacion != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${ubicacion.direccionExacta}, ${ubicacion.zonaBarrios}, ${ubicacion.ciudad}',
                            style: TextStyle(
                              color: ShadTheme.of(context).colorScheme.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                  const SizedBox(height: 24),
                  
                  // Información Crítica (Tarjetitas)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoBadge(context, Icons.bed, '${inmueble?.habitaciones ?? 0} Hab.'),
                      _buildInfoBadge(context, Icons.bathtub, '${inmueble?.banos ?? 0} Baños'),
                      _buildInfoBadge(context, Icons.square_foot, '${inmueble?.areaConstruida ?? 0} m²'),
                      _buildInfoBadge(context, Icons.attach_money, '${publicacion.precio}'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Descripción General',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    publicacion.descripcionGeneral,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation flotante con el Botón grande
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ShadButton(
          onPressed: () {
            // Acción simulada del tour
            ShadToaster.of(context).show(
              const ShadToast(
                description: Text('Solicitud de tour enviada al sistema.'),
              ),
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.vrpano),
              SizedBox(width: 8),
              Text(
                'Realizar tour',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ShadTheme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: ShadTheme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
