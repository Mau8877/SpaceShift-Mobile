import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/publicacion_repository.dart';
import '../../domain/publicacion.dart';

part 'favoritos_provider.g.dart';

@riverpod
class Favoritos extends _$Favoritos {
  @override
  FutureOr<List<Publicacion>> build() async {
    return ref.watch(publicacionRepositoryProvider).getMisFavoritos();
  }

  Future<void> toggleFavorito(Publicacion publicacion) async {
    if (publicacion.id == null) return;
    
    // Optimistic update
    final previousState = state;
    
    if (state.value != null) {
      final currentList = state.value!;
      final isFavorite = currentList.any((p) => p.id == publicacion.id);
      
      if (isFavorite) {
        state = AsyncValue.data(currentList.where((p) => p.id != publicacion.id).toList());
      } else {
        state = AsyncValue.data([...currentList, publicacion]);
      }
    }

    try {
      await ref.read(publicacionRepositoryProvider).alternarFavorito(publicacion.id!);
    } catch (e) {
      // Revert on error
      state = previousState;
      rethrow;
    }
  }

  bool isFavorito(String? id) {
    if (id == null || state.value == null) return false;
    return state.value!.any((p) => p.id == id);
  }
}
