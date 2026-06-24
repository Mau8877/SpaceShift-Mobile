import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../domain/contrato_model.dart';
import '../domain/pago_contrato_model.dart';

part 'contrato_repository.g.dart';

class ContratoRepository {
  final Dio _dio;

  ContratoRepository(this._dio);

  Future<List<Contrato>> getContratosComoPropietario() async {
    final response = await _dio.get('/contratos/propietario');
    return (response.data as List).map((c) => Contrato.fromJson(c)).toList();
  }

  Future<List<Contrato>> getContratosComoCliente() async {
    final response = await _dio.get('/contratos/cliente');
    return (response.data as List).map((c) => Contrato.fromJson(c)).toList();
  }

  Future<Contrato> getContratoPorId(String id) async {
    final response = await _dio.get('/contratos/$id');
    return Contrato.fromJson(response.data);
  }

  Future<Contrato> crearContrato(Map<String, dynamic> payload) async {
    final response = await _dio.post('/contratos', data: payload);
    return Contrato.fromJson(response.data);
  }

  Future<Contrato> firmarContrato(
    String id, {
    List<Map<String, dynamic>>? dispositivosAlquilados,
    double? montoAcordado,
  }) async {
    final response = await _dio.post(
      '/contratos/$id/firmar',
      data: {
        if (dispositivosAlquilados != null) 'dispositivosAlquilados': dispositivosAlquilados,
        if (montoAcordado != null) 'montoAcordado': montoAcordado,
      },
    );
    return Contrato.fromJson(response.data);
  }

  Future<Contrato> cancelarContrato(String id) async {
    final response = await _dio.post('/contratos/$id/cancelar');
    return Contrato.fromJson(response.data);
  }

  Future<List<PagoContrato>> getPagosDeContrato(String contratoId) async {
    final response = await _dio.get('/contratos/$contratoId/pagos');
    return (response.data as List).map((p) => PagoContrato.fromJson(p)).toList();
  }

  Future<PagoContrato> subirComprobantePago(String pagoId, String filePath) async {
    final formData = FormData.fromMap({
      'comprobante': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('/pagos/$pagoId/comprobante', data: formData);
    return PagoContrato.fromJson(response.data);
  }

  Future<Map<String, dynamic>> generarSesionPagoStripe(String pagoId, String originUrl) async {
    final response = await _dio.post(
      '/pagos/$pagoId/stripe-checkout',
      queryParameters: {'originUrl': originUrl},
    );
    return response.data;
  }
}

@riverpod
ContratoRepository contratoRepository(Ref ref) {
  return ContratoRepository(ref.watch(dioProvider));
}
