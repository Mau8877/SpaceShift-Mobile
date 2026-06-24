import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../domain/contrato_model.dart';
import '../providers/contratos_provider.dart';
import '../../../../core/network/jwt_utils.dart';
import '../../../../core/network/dio_provider.dart';

class ContratoDetailScreen extends ConsumerStatefulWidget {
  final String contratoId;

  const ContratoDetailScreen({
    super.key,
    required this.contratoId,
  });

  @override
  ConsumerState<ContratoDetailScreen> createState() => _ContratoDetailScreenState();
}

class _ContratoDetailScreenState extends ConsumerState<ContratoDetailScreen> {
  String? currentUserId;
  bool _initialized = false;
  final Map<String, bool> _selectedDevices = {};
  final Map<String, int> _deviceDays = {};

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.getToken();
    if (token != null) {
      if (mounted) {
        setState(() {
          currentUserId = JwtUtils.extractUserId(token);
        });
      }
    }
  }

  double _calculateTotal(Contrato contrato) {
    double total = contrato.monto;
    for (var dev in contrato.dispositivosInmueble) {
      if (_selectedDevices[dev.id] == true) {
        final days = _deviceDays[dev.id] ?? contrato.noches;
        total += dev.precio * days;
      }
    }
    return total;
  }

  double _calculateDevicesTotal(Contrato contrato) {
    double total = 0;
    for (var dev in contrato.dispositivosInmueble) {
      if (_selectedDevices[dev.id] == true) {
        final days = _deviceDays[dev.id] ?? contrato.noches;
        total += dev.precio * days;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final contratoAsync = ref.watch(contratoDetailProvider(widget.contratoId));
    final controllerState = ref.watch(contratoControllerProvider);
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Contrato'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: contratoAsync.when(
        data: (contrato) {
          // Initialize local state once data is loaded
          if (!_initialized) {
            for (var d in contrato.dispositivosInmueble) {
              _selectedDevices[d.id] = false;
              _deviceDays[d.id] = contrato.noches > 0 ? contrato.noches : 1;
            }
            _initialized = true;
          }

          final isOwner = currentUserId != null && (currentUserId == contrato.idPropietario);
          final isClient = currentUserId != null && (currentUserId == contrato.idCliente);
          final statusColor = _getStatusColor(contrato.estadoContrato);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(contratoDetailProvider(widget.contratoId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  ShadCard(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                contrato.inmuebleTitulo,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                contrato.estadoContrato.replaceAll('_', ' '),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Código: ${contrato.codigo}',
                          style: TextStyle(
                            color: theme.colorScheme.mutedForeground,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tipo de Contrato: ${contrato.tipoContrato}',
                          style: TextStyle(
                            color: theme.colorScheme.mutedForeground,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Parties details
                  ShadCard(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Participantes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        _buildDetailItem('Propietario', contrato.propietarioNombre, Icons.business_center),
                        const SizedBox(height: 12),
                        _buildDetailItem('Cliente / Inquilino', contrato.clienteNombre, Icons.person),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dates and Financial Details
                  ShadCard(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalles de Alquiler',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        _buildDetailItem(
                          'Vigencia',
                          '${_formatDate(contrato.fechaInicio)} al ${_formatDate(contrato.fechaFin)}',
                          Icons.calendar_today,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailItem(
                          'Duración',
                          '${contrato.noches} noches',
                          Icons.nightlight_round,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailItem(
                          'Monto Base',
                          '${contrato.moneda} ${contrato.monto.toStringAsFixed(2)}',
                          Icons.monetization_on,
                        ),
                        if (contrato.estadoContrato != 'PENDIENTE_FIRMA') ...[
                          const SizedBox(height: 12),
                          _buildDetailItem(
                            'Monto Acordado Final',
                            '${contrato.moneda} ${contrato.montoAcordado.toStringAsFixed(2)}',
                            Icons.check_circle_outline,
                            textColor: theme.colorScheme.primary,
                            isBold: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Blockchain Transaction Hash
                  if (contrato.transactionHash != null && contrato.transactionHash!.trim().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.link_off_outlined, color: theme.colorScheme.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Registro en Blockchain (Polygon)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            'Hash: ${contrato.transactionHash}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Conditions & Penalties
                  if (contrato.condicionesInmueble.isNotEmpty || contrato.multasSancionesInmueble.isNotEmpty) ...[
                    ShadCard(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reglas y Condiciones del Inmueble',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Divider(height: 20),
                          if (contrato.condicionesInmueble.isNotEmpty) ...[
                            const Text(
                              'Condiciones / Normas de Uso:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              contrato.condicionesInmueble,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (contrato.multasSancionesInmueble.isNotEmpty) ...[
                            const Text(
                              'Multas y Sanciones por Incumplimiento:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              contrato.multasSancionesInmueble,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Rented devices list if already active
                  if (contrato.especificaciones.containsKey('dispositivos_alquilados') &&
                      contrato.especificaciones['dispositivos_alquilados'] is List &&
                      (contrato.especificaciones['dispositivos_alquilados'] as List).isNotEmpty) ...[
                    ShadCard(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dispositivos Alquilados Incluidos',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Divider(height: 20),
                          ...(contrato.especificaciones['dispositivos_alquilados'] as List).map((dev) {
                            final name = dev['nombre'] ?? '';
                            final days = dev['diasUso'] ?? 1;
                            final price = (dev['precio'] ?? 0).toDouble();
                            final subtotal = price * days;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Tiempo de uso: $days días',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                        if (dev['maxHorasSeguidas'] != null && dev['maxHorasSeguidas'] > 0)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.0),
                                            child: Text(
                                              '• Máx. horas continuas: ${dev['maxHorasSeguidas']}h',
                                              style: TextStyle(color: Colors.blue.shade700, fontSize: 11),
                                            ),
                                          ),
                                        if (dev['horarioLimiteUso'] != null && dev['horarioLimiteUso'] != "")
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.0),
                                            child: Text(
                                              '• Restricción horario: ${dev['horarioLimiteUso']} - ${dev['horarioLimiteFin'] ?? ''}',
                                              style: TextStyle(color: Colors.orange.shade800, fontSize: 11),
                                            ),
                                          ),
                                        if (dev['sancionIncumplimiento'] != null && dev['sancionIncumplimiento'] != "")
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.0),
                                            child: Text(
                                              '• Sanción: ${dev['sancionIncumplimiento']}',
                                              style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${contrato.moneda} ${subtotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Smart Devices Addition panel (only client during PENDIENTE_FIRMA)
                  if (contrato.estadoContrato == 'PENDIENTE_FIRMA' && isClient && contrato.dispositivosInmueble.isNotEmpty) ...[
                    ShadCard(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.developer_board, color: Colors.indigo, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Adicionar Dispositivos Inteligentes',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Selecciona qué dispositivos inteligentes de la propiedad deseas habilitar durante tu estancia.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const Divider(height: 24),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: contrato.dispositivosInmueble.length,
                            itemBuilder: (context, index) {
                              final dev = contrato.dispositivosInmueble[index];
                              final isSelected = _selectedDevices[dev.id] ?? false;
                              final days = _deviceDays[dev.id] ?? contrato.noches;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary.withValues(alpha: 0.02)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Checkbox(
                                          value: isSelected,
                                          activeColor: theme.colorScheme.primary,
                                          onChanged: (val) {
                                            setState(() {
                                              _selectedDevices[dev.id] = val ?? false;
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dev.nombre,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                              Text(
                                                dev.descripcion,
                                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                              ),
                                              const SizedBox(height: 6),
                                              Wrap(
                                                spacing: 6,
                                                runSpacing: 4,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade100,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      '${dev.configuracionTiempo} (${dev.horarioInicio}-${dev.horarioFin})',
                                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 9, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      '${contrato.moneda} ${dev.precio} / ${dev.tipoPrecio == 'POR_DIA' ? 'día' : 'unid'}',
                                                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 9, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  if (dev.maxHorasSeguidas != null && dev.maxHorasSeguidas! > 0)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue.shade50,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        'Máx: ${dev.maxHorasSeguidas}h',
                                                        style: TextStyle(color: Colors.blue.shade700, fontSize: 9, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  if (dev.horarioLimiteUso != null && dev.horarioLimiteUso!.isNotEmpty)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange.shade50,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        'Bloqueo: ${dev.horarioLimiteUso}-${dev.horarioLimiteFin ?? ''}',
                                                        style: TextStyle(color: Colors.orange.shade800, fontSize: 9, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  if (dev.sancionIncumplimiento != null && dev.sancionIncumplimiento!.isNotEmpty)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red.shade50,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        'Sanción: ${dev.sancionIncumplimiento}',
                                                        style: TextStyle(color: Colors.red.shade800, fontSize: 9, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isSelected) ...[
                                      const Divider(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Días de uso:',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                                onPressed: days > 1
                                                    ? () {
                                                        setState(() {
                                                          _deviceDays[dev.id] = days - 1;
                                                        });
                                                      }
                                                    : null,
                                              ),
                                              Text(
                                                '$days',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                                onPressed: days < contrato.noches
                                                    ? () {
                                                        setState(() {
                                                          _deviceDays[dev.id] = days + 1;
                                                        });
                                                      }
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                          const Divider(height: 24),
                          // Price Stepper breakdown
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Alquiler Base:'),
                              Text('${contrato.moneda} ${contrato.monto.toStringAsFixed(2)}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Adicional Dispositivos:'),
                              Text('${contrato.moneda} ${_calculateDevicesTotal(contrato).toStringAsFixed(2)}'),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Monto Total Recalculado:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '${contrato.moneda} ${_calculateTotal(contrato).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Signing Button (shows during PENDIENTE_FIRMA)
                  if (contrato.estadoContrato == 'PENDIENTE_FIRMA' && (isClient || isOwner)) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ShadButton(
                        onPressed: controllerState.isLoading
                            ? null
                            : () async {
                                final totalRecalculated = _calculateTotal(contrato);
                                final chosenDevices = <Map<String, dynamic>>[];

                                for (var dev in contrato.dispositivosInmueble) {
                                  if (_selectedDevices[dev.id] == true) {
                                    final days = _deviceDays[dev.id] ?? contrato.noches;
                                    chosenDevices.add({
                                      'id': dev.id,
                                      'nombre': dev.nombre,
                                      'precio': dev.precio,
                                      'diasUso': days,
                                      'tipoPrecio': dev.tipoPrecio,
                                      'configuracionTiempo': dev.configuracionTiempo,
                                      'horarioInicio': dev.horarioInicio,
                                      'horarioFin': dev.horarioFin,
                                      'descripcion': dev.descripcion,
                                    });
                                  }
                                }

                                final toaster = ShadToaster.of(context);
                                final success = await ref
                                    .read(contratoControllerProvider.notifier)
                                    .firmarContrato(
                                      contrato.id,
                                      dispositivosAlquilados: chosenDevices.isNotEmpty ? chosenDevices : null,
                                      montoAcordado: chosenDevices.isNotEmpty ? totalRecalculated : null,
                                    );

                                if (success && mounted) {
                                  toaster.show(
                                    const ShadToast(
                                      description: Text('¡Contrato firmado digitalmente y desplegado en la Blockchain!'),
                                    ),
                                  );
                                } else if (mounted) {
                                  final errorMsg = controllerState.error?.toString() ?? 'Error al firmar';
                                  toaster.show(
                                    ShadToast.destructive(
                                      description: Text(errorMsg),
                                    ),
                                  );
                                }
                              },
                        child: controllerState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_document),
                                  SizedBox(width: 8),
                                  Text('Firmar Contrato Digitalmente'),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, {Color? textColor, bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDIENTE_FIRMA':
        return Colors.orange;
      case 'VIGENTE':
        return Colors.green;
      case 'FINALIZADO':
        return Colors.grey;
      case 'CANCELADO':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
