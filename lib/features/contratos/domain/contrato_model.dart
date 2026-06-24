class Contrato {
  final String id;
  final String codigo;
  final String idInmueble;
  final String inmuebleTitulo;
  final String idPublicacion;
  final String idPropietario;
  final String propietarioNombre;
  final String idCliente;
  final String clienteNombre;
  final String tipoContrato;
  final String estadoContrato;
  final double montoAcordado;
  final double monto;
  final String moneda;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int cantidadHuespedes;
  final int noches;
  final String? documentoUrl;
  final String? observacion;
  final Map<String, dynamic> especificaciones;
  final List<DispositivoInmueble> dispositivosInmueble;
  final String condicionesInmueble;
  final String multasSancionesInmueble;
  final String? transactionHash;
  final DateTime? createdAt;

  Contrato({
    required this.id,
    required this.codigo,
    required this.idInmueble,
    required this.inmuebleTitulo,
    required this.idPublicacion,
    required this.idPropietario,
    required this.propietarioNombre,
    required this.idCliente,
    required this.clienteNombre,
    required this.tipoContrato,
    required this.estadoContrato,
    required this.montoAcordado,
    required this.monto,
    required this.moneda,
    this.fechaInicio,
    this.fechaFin,
    required this.cantidadHuespedes,
    required this.noches,
    this.documentoUrl,
    this.observacion,
    required this.especificaciones,
    required this.dispositivosInmueble,
    required this.condicionesInmueble,
    required this.multasSancionesInmueble,
    this.transactionHash,
    this.createdAt,
  });

  factory Contrato.fromJson(Map<String, dynamic> json) {
    return Contrato(
      id: json['id'] ?? '',
      codigo: json['codigo'] ?? '',
      idInmueble: json['idInmueble'] ?? '',
      inmuebleTitulo: json['inmuebleTitulo'] ?? '',
      idPublicacion: json['idPublicacion'] ?? '',
      idPropietario: json['idPropietario'] ?? '',
      propietarioNombre: json['propietarioNombre'] ?? '',
      idCliente: json['idCliente'] ?? '',
      clienteNombre: json['clienteNombre'] ?? '',
      tipoContrato: json['tipoContrato'] ?? 'ALOJAMIENTO',
      estadoContrato: json['estadoContrato'] ?? 'PENDIENTE_FIRMA',
      montoAcordado: (json['montoAcordado'] ?? 0).toDouble(),
      monto: (json['monto'] ?? 0).toDouble(),
      moneda: json['moneda'] ?? 'USD',
      fechaInicio: json['fechaInicio'] != null ? DateTime.tryParse(json['fechaInicio']) : null,
      fechaFin: json['fechaFin'] != null ? DateTime.tryParse(json['fechaFin']) : null,
      cantidadHuespedes: json['cantidadHuespedes'] ?? 0,
      noches: json['noches'] ?? 0,
      documentoUrl: json['documentoUrl'],
      observacion: json['observacion'],
      especificaciones: json['especificaciones'] ?? {},
      dispositivosInmueble: (json['dispositivosInmueble'] as List?)
              ?.map((d) => DispositivoInmueble.fromJson(d))
              .toList() ??
          [],
      condicionesInmueble: json['condicionesInmueble'] ?? '',
      multasSancionesInmueble: json['multasSancionesInmueble'] ?? '',
      transactionHash: json['transactionHash'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : (json['createdDate'] != null ? DateTime.tryParse(json['createdDate']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'idInmueble': idInmueble,
      'inmuebleTitulo': inmuebleTitulo,
      'idPublicacion': idPublicacion,
      'idPropietario': idPropietario,
      'propietarioNombre': propietarioNombre,
      'idCliente': idCliente,
      'clienteNombre': clienteNombre,
      'tipoContrato': tipoContrato,
      'estadoContrato': estadoContrato,
      'montoAcordado': montoAcordado,
      'monto': monto,
      'moneda': moneda,
      'fechaInicio': fechaInicio?.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'cantidadHuespedes': cantidadHuespedes,
      'noches': noches,
      'documentoUrl': documentoUrl,
      'observacion': observacion,
      'especificaciones': especificaciones,
      'dispositivosInmueble': dispositivosInmueble.map((d) => d.toJson()).toList(),
      'condicionesInmueble': condicionesInmueble,
      'multasSancionesInmueble': multasSancionesInmueble,
      'transactionHash': transactionHash,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class DispositivoInmueble {
  final String id;
  final String nombre;
  final double precio;
  final String tipoPrecio;
  final String configuracionTiempo;
  final String horarioInicio;
  final String horarioFin;
  final String descripcion;
  final int? maxHorasSeguidas;
  final String? horarioLimiteUso;
  final String? horarioLimiteFin;
  final String? sancionIncumplimiento;

  DispositivoInmueble({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.tipoPrecio,
    required this.configuracionTiempo,
    required this.horarioInicio,
    required this.horarioFin,
    required this.descripcion,
    this.maxHorasSeguidas,
    this.horarioLimiteUso,
    this.horarioLimiteFin,
    this.sancionIncumplimiento,
  });

  factory DispositivoInmueble.fromJson(Map<String, dynamic> json) {
    return DispositivoInmueble(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      precio: (json['precio'] ?? json['precioPorDia'] ?? json['precio_por_dia'] ?? 0).toDouble(),
      tipoPrecio: json['tipoPrecio'] ?? 'POR_DIA',
      configuracionTiempo: json['configuracionTiempo'] ?? 'LIBRE',
      horarioInicio: json['horarioInicio'] ?? '00:00',
      horarioFin: json['horarioFin'] ?? '23:59',
      descripcion: json['descripcion'] ?? '',
      maxHorasSeguidas: json['maxHorasSeguidas'],
      horarioLimiteUso: json['horarioLimiteUso'],
      horarioLimiteFin: json['horarioLimiteFin'],
      sancionIncumplimiento: json['sancionIncumplimiento'] ?? json['sancion_incumplimiento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'tipoPrecio': tipoPrecio,
      'configuracionTiempo': configuracionTiempo,
      'horarioInicio': horarioInicio,
      'horarioFin': horarioFin,
      'descripcion': descripcion,
      if (maxHorasSeguidas != null) 'maxHorasSeguidas': maxHorasSeguidas,
      if (horarioLimiteUso != null) 'horarioLimiteUso': horarioLimiteUso,
      if (horarioLimiteFin != null) 'horarioLimiteFin': horarioLimiteFin,
      if (sancionIncumplimiento != null) 'sancionIncumplimiento': sancionIncumplimiento,
    };
  }
}
