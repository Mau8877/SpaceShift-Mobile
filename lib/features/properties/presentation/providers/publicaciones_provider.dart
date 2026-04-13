import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/publicacion_repository.dart';
import '../../domain/publicacion.dart';

part 'publicaciones_provider.g.dart';

@riverpod
Future<List<Publicacion>> publicaciones(Ref ref) {
  return ref.watch(publicacionRepositoryProvider).getPublicaciones();
}
