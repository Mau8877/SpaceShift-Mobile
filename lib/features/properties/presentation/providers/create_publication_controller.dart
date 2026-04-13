import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/inmueble_repository.dart';
import '../../data/publicacion_repository.dart';
import '../../domain/inmueble.dart';
import '../../domain/publicacion.dart';
import 'publicaciones_provider.dart';

part 'create_publication_controller.g.dart';

@riverpod
class CreatePublicationController extends _$CreatePublicationController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> createPublication(
      Inmueble inmueble, Publicacion publicacionData) async {
    state = const AsyncValue.loading();
    try {
      final inmuebleCreado =
          await ref.read(inmuebleRepositoryProvider).createInmueble(inmueble);

      final publicacionAGuardar = Publicacion(
        idUsuario: publicacionData.idUsuario,
        idInmueble: inmuebleCreado.id!,
        titulo: publicacionData.titulo,
        descripcionGeneral: publicacionData.descripcionGeneral,
        tipoTransaccion: publicacionData.tipoTransaccion,
        precio: publicacionData.precio,
        moneda: publicacionData.moneda,
        estadoPublicacion: publicacionData.estadoPublicacion,
        imagenesUrls: publicacionData.imagenesUrls,
      );

      await ref
          .read(publicacionRepositoryProvider)
          .createPublicacion(publicacionAGuardar);

      // Invalida la recarga para que the explore page fetch changes
      ref.invalidate(publicacionesProvider);
      
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
