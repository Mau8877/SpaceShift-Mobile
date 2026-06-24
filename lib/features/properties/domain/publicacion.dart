import 'inmueble.dart';

class Publicacion {
  final String? id;
  final String idUsuario;
  final String idInmueble;
  final String titulo;
  final String descripcionGeneral;
  final String tipoTransaccion;
  final double precio;
  final String moneda;
  final String estadoPublicacion;
  final List<String> imagenesUrls;
  
  // Opcional: Puede que el backend retorne el Inmueble anidado.
  // Lo manejamos si viene en el JSON.
  final Inmueble? inmueble;

  Publicacion({
    this.id,
    required this.idUsuario,
    required this.idInmueble,
    required this.titulo,
    required this.descripcionGeneral,
    required this.tipoTransaccion,
    required this.precio,
    required this.moneda,
    required this.estadoPublicacion,
    required this.imagenesUrls,
    this.inmueble,
  });

  factory Publicacion.fromJson(Map<String, dynamic> json) {
    return Publicacion(
      id: json['id'],
      idUsuario: json['idUsuario'] ?? '',
      idInmueble: json['idInmueble'] ?? 
                  (json['inmueble'] != null ? json['inmueble']['id'] ?? '' : ''),
      titulo: json['titulo'] ?? '',
      descripcionGeneral: json['descripcionGeneral'] ?? '',
      tipoTransaccion: json['tipoTransaccion'] ?? 'VENTA',
      precio: (json['precio'] ?? 0).toDouble(),
      moneda: json['moneda'] ?? 'USD',
      estadoPublicacion: json['estadoPublicacion'] ?? 'DISPONIBLE',
      imagenesUrls: (json['imagenes'] as List?)?.map((img) => img['urlImage'] as String).toList() ?? 
                    List<String>.from(json['imagenesUrls'] ?? []),
      inmueble: json['inmueble'] != null ? Inmueble.fromJson(json['inmueble']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'idUsuario': idUsuario,
      'idInmueble': idInmueble,
      'titulo': titulo,
      'descripcionGeneral': descripcionGeneral,
      'tipoTransaccion': tipoTransaccion,
      'precio': precio,
      'moneda': moneda,
      'estadoPublicacion': estadoPublicacion,
      'imagenesUrls': imagenesUrls,
      if (inmueble != null) 'inmueble': inmueble!.toJson(),
    };
  }
}
