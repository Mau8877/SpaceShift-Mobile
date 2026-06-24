import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/contrato_repository.dart';
import '../../domain/contrato_model.dart';
import '../../domain/pago_contrato_model.dart';

part 'contratos_provider.g.dart';

@riverpod
Future<List<Contrato>> contratosPropietario(Ref ref) async {
  return await ref.read(contratoRepositoryProvider).getContratosComoPropietario();
}

@riverpod
Future<List<Contrato>> contratosCliente(Ref ref) async {
  return await ref.read(contratoRepositoryProvider).getContratosComoCliente();
}

@riverpod
Future<Contrato> contratoDetail(Ref ref, String id) async {
  return await ref.read(contratoRepositoryProvider).getContratoPorId(id);
}

@riverpod
Future<List<PagoContrato>> pagosDeContrato(Ref ref, String contratoId) async {
  return await ref.read(contratoRepositoryProvider).getPagosDeContrato(contratoId);
}

@Riverpod(keepAlive: true)
class ContratoController extends _$ContratoController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<Contrato?> crearContrato(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    try {
      final res = await ref.read(contratoRepositoryProvider).crearContrato(payload);
      ref.invalidate(contratosPropietarioProvider);
      ref.invalidate(contratosClienteProvider);
      state = const AsyncValue.data(null);
      return res;
    } catch (e, st) {
      print('ERROR in crearContrato: $e');
      print(st);
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> firmarContrato(
    String id, {
    List<Map<String, dynamic>>? dispositivosAlquilados,
    double? montoAcordado,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(contratoRepositoryProvider).firmarContrato(
        id,
        dispositivosAlquilados: dispositivosAlquilados,
        montoAcordado: montoAcordado,
      );
      
      // Invalidate related providers to refresh list and detail screens
      ref.invalidate(contratosPropietarioProvider);
      ref.invalidate(contratosClienteProvider);
      ref.invalidate(contratoDetailProvider(id));
      ref.invalidate(pagosDeContratoProvider(id));
      
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> cancelarContrato(String id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(contratoRepositoryProvider).cancelarContrato(id);
      
      ref.invalidate(contratosPropietarioProvider);
      ref.invalidate(contratosClienteProvider);
      ref.invalidate(contratoDetailProvider(id));
      ref.invalidate(pagosDeContratoProvider(id));
      
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> subirComprobantePago(String pagoId, String filePath, String contratoId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(contratoRepositoryProvider).subirComprobantePago(pagoId, filePath);
      ref.invalidate(pagosDeContratoProvider(contratoId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<String?> generarSesionPagoStripe(String pagoId, String originUrl) async {
    state = const AsyncValue.loading();
    try {
      final res = await ref.read(contratoRepositoryProvider).generarSesionPagoStripe(pagoId, originUrl);
      state = const AsyncValue.data(null);
      return res['stripeCheckoutUrl'] as String?;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}
