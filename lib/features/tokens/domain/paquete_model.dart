class PaqueteCredito {
  final String id;
  final String nombrePaquete;
  final double precio;
  final String? descripcion;
  final int creditosPaquetes;

  PaqueteCredito({
    required this.id,
    required this.nombrePaquete,
    required this.precio,
    this.descripcion,
    required this.creditosPaquetes,
  });

  factory PaqueteCredito.fromJson(Map<String, dynamic> json) {
    return PaqueteCredito(
      id: json['id'] ?? '',
      nombrePaquete: json['nombrePaquete'] ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      descripcion: json['descripcion'],
      creditosPaquetes: json['creditosPaquetes'] ?? 0,
    );
  }
}
