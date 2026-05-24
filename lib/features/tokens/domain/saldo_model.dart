class SaldoCreditos {
  final String usuarioId;
  final int saldoCreditos;

  SaldoCreditos({
    required this.usuarioId,
    required this.saldoCreditos,
  });

  factory SaldoCreditos.fromJson(Map<String, dynamic> json) {
    return SaldoCreditos(
      usuarioId: json['usuarioId']?.toString() ?? '',
      saldoCreditos: json['saldoCreditos'] ?? 0,
    );
  }
}
