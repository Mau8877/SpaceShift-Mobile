import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/paquete_model.dart';
import '../domain/saldo_model.dart';
import '../domain/transaccion_model.dart';

part 'tokens_repository.g.dart';

class TokensRepository {
  final Dio _dio;

  TokensRepository(this._dio);

  Future<List<PaqueteCredito>> obtenerPaquetes() async {
    final response = await _dio.get('/tokens/paquetes');
    final List<dynamic> list = response.data;
    return list.map((json) => PaqueteCredito.fromJson(json)).toList();
  }

  Future<SaldoCreditos> obtenerSaldo() async {
    final response = await _dio.get('/tokens/saldo');
    return SaldoCreditos.fromJson(response.data);
  }

  Future<List<TransaccionCredito>> obtenerHistorial({int page = 0, int size = 10}) async {
    final response = await _dio.get(
      '/tokens/historial',
      queryParameters: {'page': page, 'size': size},
    );
    final List<dynamic> content = response.data['content'] ?? [];
    return content.map((json) => TransaccionCredito.fromJson(json)).toList();
  }

  // Generación de Checkout Session de Stripe
  Future<String> comprarPaquete(String paqueteId) async {
    final response = await _dio.post(
      '/checkout/session',
      data: {'paqueteId': paqueteId},
    );
    return response.data['checkoutUrl'] ?? '';
  }
}

@riverpod
TokensRepository tokensRepository(Ref ref) {
  return TokensRepository(ref.watch(dioProvider));
}
