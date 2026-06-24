import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../properties/domain/publicacion.dart';
import '../providers/crear_oferta_provider.dart';
import '../widgets/contract_payment_and_signature_layout.dart';
import '../widgets/property_header_card.dart';
import '../widgets/device_selection_list.dart';
import '../widgets/rental_summary_card.dart';

class CrearOfertaScreen extends ConsumerStatefulWidget {
  final Publicacion publicacion;

  const CrearOfertaScreen({
    super.key,
    required this.publicacion,
  });

  @override
  ConsumerState<CrearOfertaScreen> createState() => _CrearOfertaScreenState();
}

class _CrearOfertaScreenState extends ConsumerState<CrearOfertaScreen> {
  final TextEditingController _observacionController = TextEditingController();

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  // Helper properties
  bool get _isRental =>
      widget.publicacion.tipoTransaccion.toUpperCase() == 'ALQUILER' ||
      widget.publicacion.tipoTransaccion.toUpperCase() == 'ALOJAMIENTO';

  bool get _isAnticretico =>
      widget.publicacion.tipoTransaccion.toUpperCase() == 'ANTICRETICO';

  bool get _showDates => _isRental || _isAnticretico;

  double get _precioBase => widget.publicacion.precio;
  String get _moneda => widget.publicacion.moneda;

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar fecha';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context, bool isStart, DateTime? currentDate, CrearOfertaFormNotifier notifier) async {
    final initialDate = DateTime.now();
    final firstDate = DateTime.now().subtract(const Duration(days: 1));
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (currentDate ?? initialDate)
          : (currentDate ?? initialDate.add(const Duration(days: 1))),
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (!mounted) return;

    if (picked != null) {
      if (isStart) {
        notifier.selectStartDate(picked);
      } else {
        if (currentDate != null && picked.isBefore(currentDate)) {
          ShadToaster.of(context).show(
            const ShadToast.destructive(
              description: Text('La fecha de fin no puede ser anterior a la de inicio'),
            ),
          );
        } else {
          notifier.selectEndDate(picked);
        }
      }
    }
  }

  Future<void> _submitContract(CrearOfertaFormState formState, CrearOfertaFormNotifier formNotifier) async {
    final error = await formNotifier.submitContract(
      publicacion: widget.publicacion,
      observacion: _observacionController.text,
    );
    if (!mounted) return;

    if (error == null) {
      ShadToaster.of(context).show(
        const ShadToast(
          description: Text('¡Oferta de contrato creada con éxito!'),
        ),
      );
    } else {
      ShadToaster.of(context).show(
        ShadToast.destructive(
          description: Text(error),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(crearOfertaFormProvider);
    final formNotifier = ref.read(crearOfertaFormProvider.notifier);

    if (formState.contratoCreado != null) {
      return ContractPaymentAndSignatureLayout(
        contrato: formState.contratoCreado!,
        onBack: () => formNotifier.reset(),
      );
    }

    final theme = ShadTheme.of(context);

    final nights = formState.getNights();
    final totalDevices = formState.calculateTotalDevices(widget.publicacion);
    final totalFinal = formState.calculateTotalFinal(widget.publicacion);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear oferta de contrato'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property details header
              PropertyHeaderCard(publicacion: widget.publicacion),
              const SizedBox(height: 20),

              // Date Form Fields
              if (_showDates) ...[
                Text(
                  'Fechas de estancia',
                  style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true, formState.fechaInicio, formNotifier),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fecha de inicio', style: theme.textTheme.muted.copyWith(fontSize: 11)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 16, color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _formatDate(formState.fechaInicio),
                                      style: theme.textTheme.p.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false, formState.fechaInicio, formNotifier),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fecha de fin', style: theme.textTheme.muted.copyWith(fontSize: 11)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 16, color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _formatDate(formState.fechaFin),
                                      style: theme.textTheme.p.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Smart Devices Grid
              if (widget.publicacion.inmueble != null &&
                  widget.publicacion.inmueble!.dispositivos.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      'Dispositivos inteligentes opcionales',
                      style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecciona los dispositivos que deseas rentar e integrar en tu contrato.',
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: 12),
                DeviceSelectionList(
                  dispositivos: widget.publicacion.inmueble!.dispositivos,
                  selectedDeviceIds: formState.dispositivosSeleccionados,
                  onToggle: (id) => formNotifier.toggleDevice(id),
                  moneda: _moneda,
                ),
                const SizedBox(height: 24),
              ],

              // Observaciones
              Text(
                'Observaciones adicionales',
                style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _observacionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Requerimientos especiales, comentarios para el propietario...',
                  hintStyle: TextStyle(color: theme.colorScheme.mutedForeground),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.border),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Summary Card
              RentalSummaryCard(
                isRental: _isRental,
                moneda: _moneda,
                precioBase: _precioBase,
                nights: nights,
                dispositivosCount: formState.dispositivosSeleccionados.length,
                totalDevices: totalDevices,
                totalFinal: totalFinal,
                isLoading: formState.isLoading,
                onSubmit: () => _submitContract(formState, formNotifier),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
