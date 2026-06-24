class PagoContrato {
  final String id;
  final String idContrato;
  final double monto;
  final String moneda;
  final String tipoPago;
  final String estadoPago;
  final String? metodoPago;
  final String fechaVencimiento;
  final DateTime? fechaPago;
  final String? documentoComprobanteUrl;
  final String? stripePagoId;

  PagoContrato({
    required this.id,
    required this.idContrato,
    required this.monto,
    required this.moneda,
    required this.tipoPago,
    required this.estadoPago,
    this.metodoPago,
    required this.fechaVencimiento,
    this.fechaPago,
    this.documentoComprobanteUrl,
    this.stripePagoId,
  });

  factory PagoContrato.fromJson(Map<String, dynamic> json) {
    return PagoContrato(
      id: json['id'] ?? '',
      idContrato: json['idContrato'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      moneda: json['moneda'] ?? 'Bs.',
      tipoPago: json['tipoPago'] ?? 'INICIAL',
      estadoPago: json['estadoPago'] ?? 'PENDIENTE',
      metodoPago: json['metodoPago'],
      fechaVencimiento: json['fechaVencimiento'] ?? '',
      fechaPago: json['fechaPago'] != null ? DateTime.tryParse(json['fechaPago']) : null,
      documentoComprobanteUrl: json['documentoComprobanteUrl'],
      stripePagoId: json['stripePagoId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idContrato': idContrato,
      'monto': monto,
      'moneda': moneda,
      'tipoPago': tipoPago,
      'estadoPago': estadoPago,
      if (metodoPago != null) 'metodoPago': metodoPago,
      'fechaVencimiento': fechaVencimiento,
      if (fechaPago != null) 'fechaPago': fechaPago?.toIso8601String(),
      if (documentoComprobanteUrl != null) 'documentoComprobanteUrl': documentoComprobanteUrl,
      if (stripePagoId != null) 'stripePagoId': stripePagoId,
    };
  }
}
