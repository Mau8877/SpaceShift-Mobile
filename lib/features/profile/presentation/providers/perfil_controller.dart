import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/perfil_repository.dart';
import '../../domain/perfil_model.dart';

part 'perfil_controller.g.dart';

@riverpod
class PerfilController extends _$PerfilController {
  @override
  FutureOr<Perfil?> build() async {
    return await ref.read(perfilRepositoryProvider).obtenerMiPerfil();
  }

  Future<bool> actualizarPerfil(PerfilPatchRequestFull request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(perfilRepositoryProvider).actualizarMiPerfil(request),
    );
    return !state.hasError;
  }

  Future<Perfil> obtenerPerfil(String idUsuario) async {
    return await ref.read(perfilRepositoryProvider).obtenerPerfilPorUsuario(idUsuario);
  }
}