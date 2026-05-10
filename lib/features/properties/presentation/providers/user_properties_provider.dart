import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/publicacion_repository.dart';
import '../../domain/publicacion.dart';

part 'user_properties_provider.g.dart';

@riverpod
Future<List<Publicacion>> userProperties(Ref ref) async {
  return ref.watch(publicacionRepositoryProvider).getMisPublicaciones();
}
