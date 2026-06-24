import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/jwt_utils.dart';
import '../../../properties/domain/publicacion.dart';
import '../../domain/contrato_model.dart';
import 'contratos_provider.dart';

part 'crear_oferta_provider.g.dart';

class CrearOfertaFormState {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final Set<String> dispositivosSeleccionados;
  final bool isLoading;
  final Contrato? contratoCreado;

  CrearOfertaFormState({
    this.fechaInicio,
    this.fechaFin,
    this.dispositivosSeleccionados = const {},
    this.isLoading = false,
    this.contratoCreado,
  });

  CrearOfertaFormState copyWith({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    Set<String>? dispositivosSeleccionados,
    bool? isLoading,
    Contrato? contratoCreado,
    bool clearContratoCreado = false,
  }) {
    return CrearOfertaFormState(
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      dispositivosSeleccionados: dispositivosSeleccionados ?? this.dispositivosSeleccionados,
      isLoading: isLoading ?? this.isLoading,
      contratoCreado: clearContratoCreado ? null : (contratoCreado ?? this.contratoCreado),
    );
  }
}

extension CrearOfertaFormStateCalculations on CrearOfertaFormState {
  int getNights() {
    if (fechaInicio == null || fechaFin == null) return 0;
    return fechaFin!.difference(fechaInicio!).inDays;
  }

  double calculateTotalDevices(Publicacion publicacion) {
    if (publicacion.inmueble == null) return 0.0;
    final nights = getNights();
    final isRental = publicacion.tipoTransaccion.toUpperCase() == 'ALQUILER' ||
        publicacion.tipoTransaccion.toUpperCase() == 'ALOJAMIENTO';
    double total = 0.0;
    for (final dev in publicacion.inmueble!.dispositivos) {
      if (dispositivosSeleccionados.contains(dev.id)) {
        final dias = isRental ? (nights > 0 ? nights : 1) : 1;
        total += dev.precio * dias;
      }
    }
    return total;
  }

  double calculateTotalFinal(Publicacion publicacion) {
    final isRental = publicacion.tipoTransaccion.toUpperCase() == 'ALQUILER' ||
        publicacion.tipoTransaccion.toUpperCase() == 'ALOJAMIENTO';
    final nights = getNights();
    final totalDevices = calculateTotalDevices(publicacion);
    return isRental ? (publicacion.precio * nights) + totalDevices : publicacion.precio;
  }
}

@riverpod
class CrearOfertaFormNotifier extends _$CrearOfertaFormNotifier {
  @override
  CrearOfertaFormState build() {
    return CrearOfertaFormState();
  }

  void selectStartDate(DateTime date) {
    DateTime? currentEnd = state.fechaFin;
    if (currentEnd != null && currentEnd.isBefore(date)) {
      currentEnd = date.add(const Duration(days: 1));
    }
    state = state.copyWith(
      fechaInicio: date,
      fechaFin: currentEnd,
    );
  }

  void selectEndDate(DateTime date) {
    state = state.copyWith(fechaFin: date);
  }

  void toggleDevice(String id) {
    final updated = Set<String>.from(state.dispositivosSeleccionados);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = state.copyWith(dispositivosSeleccionados: updated);
  }

  void reset() {
    state = CrearOfertaFormState();
  }

  Future<String?> submitContract({
    required Publicacion publicacion,
    required String observacion,
  }) async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final token = await tokenStorage.getToken();
    if (token == null) {
      return 'Debes iniciar sesión para realizar una oferta.';
    }

    final clientId = JwtUtils.extractUserId(token);
    if (clientId == null) {
      return 'No se pudo obtener la identidad de tu sesión.';
    }

    final isRental = publicacion.tipoTransaccion.toUpperCase() == 'ALQUILER' ||
        publicacion.tipoTransaccion.toUpperCase() == 'ALOJAMIENTO';
    final isAnticretico = publicacion.tipoTransaccion.toUpperCase() == 'ANTICRETICO';
    final showDates = isRental || isAnticretico;

    if (showDates && (state.fechaInicio == null || state.fechaFin == null)) {
      return 'Por favor, selecciona las fechas de inicio y fin.';
    }

    final nights = state.getNights();
    if (isRental && nights <= 0) {
      return 'La duración del contrato debe ser de al menos 1 noche.';
    }

    state = state.copyWith(isLoading: true);

    String mapTipoContrato() {
      final tipo = publicacion.tipoTransaccion.toUpperCase();
      if (tipo == 'ALQUILER') return 'ALQUILER';
      if (tipo == 'ALOJAMIENTO' || tipo == 'RESERVA_TEMPORAL' || tipo == 'AIRBNB') {
        return 'ALOJAMIENTO';
      }
      if (tipo == 'ANTICRETICO') return 'ANTICRETICO';
      return 'VENTA';
    }

    final totalDevices = state.calculateTotalDevices(publicacion);
    final totalFinal = state.calculateTotalFinal(publicacion);

    final selectedDevices = publicacion.inmueble?.dispositivos
            .where((d) => state.dispositivosSeleccionados.contains(d.id))
            .toList() ??
        [];

    final dispositivosContrato = selectedDevices.map((d) {
      final precioContrato = d.precio * (isRental ? nights : 1);
      return {
        'id': d.id,
        'nombre': d.nombre,
        'descripcion': d.descripcion,
        'precioPorDia': d.precio,
        'precioContrato': precioContrato,
        'cantidad': 1,
        'configuracionTiempo': d.configuracionTiempo,
        'horarioInicio': d.horarioInicio,
        'horarioFin': d.horarioFin,
        'fechaInicioUso': state.fechaInicio?.toIso8601String().split('T').first,
        'fechaFinUso': state.fechaFin?.toIso8601String().split('T').first,
      };
    }).toList();

    final payload = {
      'idInmueble': publicacion.idInmueble.isNotEmpty
          ? publicacion.idInmueble
          : (publicacion.inmueble?.id ?? ''),
      'idPublicacion': publicacion.id,
      'idCliente': clientId,
      'tipoContrato': mapTipoContrato(),
      if (state.fechaInicio != null)
        'fechaInicio': state.fechaInicio!.toIso8601String().split('T').first,
      if (state.fechaFin != null)
        'fechaFin': state.fechaFin!.toIso8601String().split('T').first,
      'montoAcordado': totalFinal,
      'moneda': publicacion.moneda,
      if (observacion.isNotEmpty)
        'observacion': observacion,
      'especificaciones': {
        'precioBasePublicacion': publicacion.precio,
        'precioDispositivosTotal': totalDevices,
        'dispositivosContrato': dispositivosContrato,
        'condicionesInmueble': publicacion.inmueble?.condiciones ?? '',
        'multasSancionesInmueble': publicacion.inmueble?.multasSanciones ?? '',
        'reglasContrato': publicacion.inmueble?.condiciones ?? '',
        'sancionesContrato': publicacion.inmueble?.multasSanciones ?? '',
      },
    };

    try {
      final contrato = await ref
          .read(contratoControllerProvider.notifier)
          .crearContrato(payload);

      if (contrato != null) {
        state = state.copyWith(
          isLoading: false,
          contratoCreado: contrato,
        );
        return null;
      } else {
        state = state.copyWith(isLoading: false);
        return 'Error al enviar la oferta. Inténtalo de nuevo.';
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'Error inesperado al enviar la oferta: $e';
    }
  }
}
