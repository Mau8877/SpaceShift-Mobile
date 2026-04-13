class ChatSummary {
  final String conversacionId;
  final String tituloPropiedad;
  final String otroUsuarioId;
  final String nombreOtroUsuario;
  final String fotoOtroUsuario;
  final DateTime ultimoMensajeFecha;

  ChatSummary({
    required this.conversacionId,
    required this.tituloPropiedad,
    required this.otroUsuarioId,
    required this.nombreOtroUsuario,
    required this.fotoOtroUsuario,
    required this.ultimoMensajeFecha,
  });

  factory ChatSummary.fromJson(Map<String, dynamic> json) {
    return ChatSummary(
      conversacionId: json['conversacionId']?.toString() ?? '',
      tituloPropiedad: json['tituloPropiedad']?.toString() ?? 'Sin título',
      otroUsuarioId: json['otroUsuarioId']?.toString() ?? '',
      nombreOtroUsuario: json['nombreOtroUsuario']?.toString() ?? 'Usuario',
      fotoOtroUsuario: json['fotoOtroUsuario']?.toString() ?? '',
      ultimoMensajeFecha: json['ultimoMensajeFecha'] != null 
          ? DateTime.tryParse(json['ultimoMensajeFecha'].toString()) ?? DateTime.now() 
          : DateTime.now(),
    );
  }
}
