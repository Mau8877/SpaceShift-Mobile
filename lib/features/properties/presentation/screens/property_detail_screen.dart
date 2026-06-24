import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

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
    
    // Coordenadas para el mapa
    final lat = double.tryParse(ubicacion?.latitud ?? '') ?? 0;
    final lng = double.tryParse(ubicacion?.longitud ?? '') ?? 0;
    final hasLocation = lat != 0 && lng != 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(publicacion.titulo, style: const TextStyle(fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ShadTheme.of(context).colorScheme.foreground,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galería de Imágenes (Carrusel simple)
            _buildImageGallery(context),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Precio y Tipo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${publicacion.moneda} ${publicacion.precio.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ShadTheme.of(context).colorScheme.primary,
                        ),
                      ),
                      ShadBadge.secondary(
                        child: Text(publicacion.tipoTransaccion),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Título
                  Text(
                    publicacion.titulo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Ubicación Texto
                  if (ubicacion != null)
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, 
                             size: 18, 
                             color: ShadTheme.of(context).colorScheme.mutedForeground),
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
                  
                  // Grid de Atributos principales
                  _buildAttributesGrid(context),
                  
                  const SizedBox(height: 32),
                  
                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    publicacion.descripcionGeneral,
                    style: TextStyle(
                      fontSize: 16, 
                      height: 1.5,
                      color: ShadTheme.of(context).colorScheme.foreground.withOpacity(0.8),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // MAPA DE UBICACIÓN
                  const Text(
                    'Ubicación en el mapa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (hasLocation)
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(lat, lng),
                            initialZoom: 15,
                            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.spaceshift.app.mobile.v1',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(lat, lng),
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Center(child: Text('Ubicación no disponible en el mapa')),
                  
                  const SizedBox(height: 100), // Espacio para el botón inferior
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Acción flotante premium
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ShadButton.outline(
                size: ShadButtonSize.lg,
                onPressed: () {
                  ShadToaster.of(context).show(
                    const ShadToast(description: Text('Iniciando contacto con el anunciante...')),
                  );
                },
                child: const Icon(Icons.chat_bubble_outline),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 5,
              child: ShadButton(
                size: ShadButtonSize.lg,
                onPressed: () {
                  context.push('/crear-oferta', extra: publicacion);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined),
                    SizedBox(width: 8),
                    Text('Realizar Oferta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    final images = publicacion.imagenesUrls;
    if (images.isEmpty) {
      return Container(
        height: 350,
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
      );
    }

    return SizedBox(
      height: 380,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Image.network(
            images[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade100,
              child: const Icon(Icons.broken_image),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttributesGrid(BuildContext context) {
    final inmueble = publicacion.inmueble;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.secondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _attributeItem(Icons.bed_outlined, '${inmueble?.habitaciones ?? 0}', 'Hab.'),
          _attributeItem(Icons.bathtub_outlined, '${inmueble?.banos ?? 0}', 'Baños'),
          _attributeItem(Icons.square_foot_outlined, '${inmueble?.areaConstruida ?? 0}', 'm²'),
          _attributeItem(Icons.directions_car_outlined, '${inmueble?.garajes ?? 0}', 'Gar.'),
        ],
      ),
    );
  }

  Widget _attributeItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
