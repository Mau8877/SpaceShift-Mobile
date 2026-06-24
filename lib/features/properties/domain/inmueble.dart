import 'ubicacion.dart';
import '../../contratos/domain/contrato_model.dart';

class Inmueble {
  final String? id;
  final String tipoInmueble;
  final double areaTerreno;
  final double areaConstruida;
  final int habitaciones;
  final int banos;
  final int garajes;
  final int antiguedadAnios;
  final Ubicacion ubicacion;
  final String? condiciones;
  final String? multasSanciones;
  final List<DispositivoInmueble> dispositivos;

  Inmueble({
    this.id,
    required this.tipoInmueble,
    required this.areaTerreno,
    required this.areaConstruida,
    required this.habitaciones,
    required this.banos,
    required this.garajes,
    required this.antiguedadAnios,
    required this.ubicacion,
    this.condiciones,
    this.multasSanciones,
    this.dispositivos = const [],
  });

  factory Inmueble.fromJson(Map<String, dynamic> json) {
    return Inmueble(
      id: json['id'],
      tipoInmueble: json['tipoInmueble'] ?? 'CASA',
      areaTerreno: (json['areaTerreno'] ?? 0).toDouble(),
      areaConstruida: (json['areaConstruida'] ?? 0).toDouble(),
      habitaciones: json['habitaciones'] ?? 0,
      banos: json['banos'] ?? 0,
      garajes: json['garajes'] ?? 0,
      antiguedadAnios: json['antiguedadAnios'] ?? 0,
      ubicacion: Ubicacion.fromJson(json['ubicacion'] ?? {}),
      condiciones: json['condiciones'],
      multasSanciones: json['multasSanciones'],
      dispositivos: (json['dispositivos'] as List?)
              ?.map((d) => DispositivoInmueble.fromJson(d))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tipoInmueble': tipoInmueble,
      'areaTerreno': areaTerreno,
      'areaConstruida': areaConstruida,
      'habitaciones': habitaciones,
      'banos': banos,
      'garajes': garajes,
      'antiguedadAnios': antiguedadAnios,
      'ubicacion': ubicacion.toJson(),
      'condiciones': condiciones,
      'multasSanciones': multasSanciones,
      'dispositivos': dispositivos.map((d) => d.toJson()).toList(),
    };
  }
}
