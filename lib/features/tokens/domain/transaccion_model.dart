class TransaccionCredito {
  final String id;
  final int cantidad;
  final String tipo;
  final String? descripcion;
  final DateTime? createdDate;

  TransaccionCredito({
    required this.id,
    required this.cantidad,
    required this.tipo,
    this.descripcion,
    this.createdDate,
  });

  factory TransaccionCredito.fromJson(Map<String, dynamic> json) {
    return TransaccionCredito(
      id: json['id'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      tipo: json['tipo'] ?? '',
      descripcion: json['descripcion'],
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'])
          : null,
    );
  }
}
