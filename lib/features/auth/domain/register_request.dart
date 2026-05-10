class RegisterRequest {
  final String correo;
  final String password;
  final String nombre;
  final String apellido;
  final String? fotoUrl;
  final String tipoPerfil;

  RegisterRequest({
    required this.correo,
    required this.password,
    required this.nombre,
    required this.apellido,
    this.fotoUrl,
    required this.tipoPerfil,
  });

  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
      'password': password,
      'nombre': nombre,
      'apellido': apellido,
      'fotoUrl': fotoUrl,
      'tipoPerfil': tipoPerfil,
    };
  }
}

enum TipoPerfil {
  empresa('EMPRESA', 'Empresa'),
  personal('PERSONAL', 'Personal');

  final String value;
  final String label;
  const TipoPerfil(this.value, this.label);
}