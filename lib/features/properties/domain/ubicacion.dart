class Ubicacion {
  final String? id;
  final String ciudad;
  final String zonaBarrios;
  final String direccionExacta;
  final String latitud;
  final String longitud;

  Ubicacion({
    this.id,
    required this.ciudad,
    required this.zonaBarrios,
    required this.direccionExacta,
    required this.latitud,
    required this.longitud,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      id: json['id'],
      ciudad: json['ciudad'] ?? '',
      zonaBarrios: json['zonaBarrios'] ?? '',
      direccionExacta: json['direccionExacta'] ?? '',
      latitud: json['latitud'] ?? '',
      longitud: json['longitud'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'ciudad': ciudad,
      'zonaBarrios': zonaBarrios,
      'direccionExacta': direccionExacta,
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}
