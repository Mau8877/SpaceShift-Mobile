class ChatMessage {
  final String id;
  final String conversacionId;
  final String remitenteId;
  final String contenido;
  final String estado;
  final DateTime creadoEn;

  ChatMessage({
    required this.id,
    required this.conversacionId,
    required this.remitenteId,
    required this.contenido,
    required this.estado,
    required this.creadoEn,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      conversacionId: json['conversacionId']?.toString() ?? '',
      remitenteId: json['remitenteId']?.toString() ?? '',
      contenido: json['contenido']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'ENVIADO',
      creadoEn: DateTime.parse(json['creadoEn']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversacionId': conversacionId,
      'remitenteId': remitenteId,
      'contenido': contenido,
      'estado': estado,
      // Se formatea en UTC por conveniencia, o isO8601String() estándar.
      'creadoEn': creadoEn.toIso8601String(),
    };
  }
}
