import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/publicaciones_provider.dart';
import '../../domain/publicacion.dart';
import '../../data/publicacion_repository.dart';
import '../../../videos/presentation/widgets/video_upload_dialog.dart';

class MisInmueblesScreen extends ConsumerWidget {
  const MisInmueblesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPropsAsync = ref.watch(misPublicacionesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Inmuebles'),
      ),
      body: userPropsAsync.when(
        data: (publicaciones) {
          if (publicaciones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.house_siding, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Aún no tienes publicaciones', 
                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ShadButton(
                    onPressed: () => context.push('/create_publication'),
                    child: const Text('Publicar mi primer inmueble'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: publicaciones.length,
            itemBuilder: (context, index) {
              final pub = publicaciones[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildManagementCard(context, pub, ref),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildManagementCard(BuildContext context, Publicacion pub, WidgetRef ref) {
    return ShadCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Miniatura
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 100,
              height: 100,
              child: pub.imagenesUrls.isNotEmpty
                  ? Image.network(pub.imagenesUrls.first, fit: BoxFit.cover)
                  : Container(color: Colors.grey.shade200),
            ),
          ),
          const SizedBox(width: 12),
          
          // Info y Acciones
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pub.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${pub.moneda} ${pub.precio.toStringAsFixed(0)}',
                  style: TextStyle(color: ShadTheme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ShadButton.outline(
                      size: ShadButtonSize.sm,
                      onPressed: () {
                        context.push('/create_publication', extra: pub);
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 14),
                          SizedBox(width: 4),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    ShadButton.destructive(
                      size: ShadButtonSize.sm,
                      onPressed: () {
                         _confirmDelete(context, pub, ref);
                      },
                      child: const Icon(Icons.delete_outline, size: 14),
                    ),
                    ShadButton(
                      size: ShadButtonSize.sm,
                      onPressed: () {
                        if (pub.id != null) {
                          showVideoUploadFlow(context, ref, pub.id!);
                        }
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.video_call, size: 14),
                          SizedBox(width: 4),
                          Text('3D'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Publicacion pub, WidgetRef ref) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('¿Eliminar publicación?'),
        description: const Text('Esta acción no se puede deshacer.'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ShadButton.destructive(
            onPressed: () async {
              try {
                final repository = ref.read(publicacionRepositoryProvider);
                await (repository as dynamic).deletePublicacion(pub.id!);
                
                // Refrescamos las listas
                ref.invalidate(misPublicacionesProvider);
                
                if (context.mounted) {
                  Navigator.of(context).pop(); // Cerramos el diálogo
                  ShadToaster.of(context).show(
                    const ShadToast(description: Text('Publicación eliminada correctamente')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ShadToaster.of(context).show(
                    ShadToast.destructive(description: Text('Error al eliminar: $e')),
                  );
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
