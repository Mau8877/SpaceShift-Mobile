class Perfil {
  final String correo;
  final String nombre;
  final String apellido;
  final String? fotoUrl;
  final String? telefono;
  final String? descripcion;
  final String? tipoPerfil;
  final bool? estadoConexion;

  Perfil({
    required this.correo,
    required this.nombre,
    required this.apellido,
    this.fotoUrl,
    this.telefono,
    this.descripcion,
    this.tipoPerfil,
    this.estadoConexion,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      correo: json['correo'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      fotoUrl: json['fotoUrl'],
      telefono: json['telefono'],
      descripcion: json['descripcion'],
      tipoPerfil: json['tipoPerfil'],
      estadoConexion: json['estadoConexion'],
    );
  }
}

class PerfilPatchRequest {
  final String? nombre;
  final String? apellido;
  final String? fotoUrl;
  final String? telefono;
  final String? descripcion;

  PerfilPatchRequest({
    this.nombre,
    this.apellido,
    this.fotoUrl,
    this.telefono,
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (nombre != null) map['nombre'] = nombre;
    if (apellido != null) map['apellido'] = apellido;
    if (fotoUrl != null) map['fotoUrl'] = fotoUrl;
    if (telefono != null) map['telefono'] = telefono;
    if (descripcion != null) map['descripcion'] = descripcion;
    return map;
  }
}

class PerfilPatchRequestFull {
  final String? correo;
  final bool? estadoConexion;
  final String? tipoPerfil;
  final String? nombre;
  final String? apellido;
  final String? fotoUrl;
  final String? telefono;
  final String? descripcion;

  PerfilPatchRequestFull({
    this.correo,
    this.estadoConexion,
    this.tipoPerfil,
    this.nombre,
    this.apellido,
    this.fotoUrl,
    this.telefono,
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (correo != null) map['correo'] = correo;
    if (estadoConexion != null) map['estadoConexion'] = estadoConexion;
    if (tipoPerfil != null) map['tipoPerfil'] = tipoPerfil;
    if (nombre != null) map['nombre'] = nombre;
    if (apellido != null) map['apellido'] = apellido;
    if (fotoUrl != null) map['fotoUrl'] = fotoUrl;
    if (telefono != null) map['telefono'] = telefono;
    if (descripcion != null) map['descripcion'] = descripcion;
    return map;
  }
}