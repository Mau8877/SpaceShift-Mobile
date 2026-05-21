import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/publicacion_repository.dart';
import '../../domain/publicacion.dart';

final userPropertiesProvider = FutureProvider<List<Publicacion>>((ref) async {
  return (ref.watch(publicacionRepositoryProvider) as dynamic)
      .getMisPublicaciones() as Future<List<Publicacion>>;
});
