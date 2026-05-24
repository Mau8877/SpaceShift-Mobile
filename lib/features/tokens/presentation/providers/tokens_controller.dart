import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/tokens_repository.dart';
import '../../domain/paquete_model.dart';
import '../../domain/saldo_model.dart';
import '../../domain/transaccion_model.dart';

part 'tokens_controller.g.dart';

@riverpod
class SaldoController extends _$SaldoController {
  @override
  FutureOr<SaldoCreditos?> build() async {
    try {
      return await ref.read(tokensRepositoryProvider).obtenerSaldo();
    } catch (e) {
      return null;
    }
  }

  Future<void> refrescarSaldo() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(tokensRepositoryProvider).obtenerSaldo();
    });
  }
}

@riverpod
Future<List<PaqueteCredito>> paquetesCredito(Ref ref) async {
  return await ref.watch(tokensRepositoryProvider).obtenerPaquetes();
}

@riverpod
Future<List<TransaccionCredito>> historialTransacciones(Ref ref) async {
  return await ref.watch(tokensRepositoryProvider).obtenerHistorial();
}
