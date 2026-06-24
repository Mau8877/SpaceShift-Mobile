import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../domain/contrato_model.dart';

class DeviceSelectionList extends StatelessWidget {
  final List<DispositivoInmueble> dispositivos;
  final Set<String> selectedDeviceIds;
  final ValueChanged<String> onToggle;
  final String moneda;

  const DeviceSelectionList({
    super.key,
    required this.dispositivos,
    required this.selectedDeviceIds,
    required this.onToggle,
    required this.moneda,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: dispositivos.map((dev) {
        final isSelected = selectedDeviceIds.contains(dev.id);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.border.withOpacity(0.5),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          color: isSelected
              ? (isDark ? Colors.indigo.shade900.withOpacity(0.3) : Colors.indigo.shade50.withOpacity(0.3))
              : Colors.transparent,
          child: InkWell(
            onTap: () => onToggle(dev.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggle(dev.id),
                    activeColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dev.nombre,
                          style: theme.textTheme.p.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (dev.descripcion.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            dev.descripcion,
                            style: theme.textTheme.muted.copyWith(fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time_outlined, size: 12, color: theme.colorScheme.mutedForeground),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                dev.configuracionTiempo == 'HORARIO'
                                    ? 'Horario: ${dev.horarioInicio} - ${dev.horarioFin}'
                                    : 'Uso Libre',
                                style: theme.textTheme.muted.copyWith(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        if (dev.maxHorasSeguidas != null && dev.maxHorasSeguidas! > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.timer_outlined, size: 12, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Máx. horas continuas: ${dev.maxHorasSeguidas}h',
                                  style: theme.textTheme.muted.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (dev.horarioLimiteUso != null && dev.horarioLimiteUso!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.block_flipped, size: 12, color: Colors.orange.shade700),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Restricción de horario: ${dev.horarioLimiteUso} - ${dev.horarioLimiteFin ?? ''}',
                                  style: theme.textTheme.muted.copyWith(fontSize: 11, color: Colors.orange.shade700, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (dev.sancionIncumplimiento != null && dev.sancionIncumplimiento!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.gavel_outlined, size: 12, color: Colors.red),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Sanción: ${dev.sancionIncumplimiento}',
                                  style: theme.textTheme.muted.copyWith(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    '$moneda ${dev.precio.toStringAsFixed(1)} / día',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? theme.colorScheme.primary : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
