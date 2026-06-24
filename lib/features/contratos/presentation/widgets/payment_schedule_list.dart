import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../domain/pago_contrato_model.dart';

class PaymentScheduleList extends StatelessWidget {
  final List<PagoContrato> pagos;
  final bool isUploading;
  final ValueChanged<PagoContrato> onStripePayment;
  final ValueChanged<PagoContrato> onUploadReceipt;

  const PaymentScheduleList({
    super.key,
    required this.pagos,
    required this.isUploading,
    required this.onStripePayment,
    required this.onUploadReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: pagos.map((pago) {
        final isCompleted = pago.estadoPago == 'COMPLETADO';
        final isRevision = pago.estadoPago == 'EN_REVISION';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.border.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pago.tipoPago.replaceFirst('_', ' ').toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isCompleted)
                    ShadBadge(
                      backgroundColor: Colors.green.shade50,
                      hoverBackgroundColor: Colors.green.shade50,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.green, size: 12),
                          SizedBox(width: 4),
                          Text('Pagado', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  else if (isRevision)
                    ShadBadge(
                      backgroundColor: Colors.blue.shade50,
                      hoverBackgroundColor: Colors.blue.shade50,
                      child: const Text('En Revisión', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  else
                    ShadBadge(
                      backgroundColor: pago.metodoPago == 'EFECTIVO' ? Colors.amber.shade50 : Colors.red.shade50,
                      hoverBackgroundColor: pago.metodoPago == 'EFECTIVO' ? Colors.amber.shade50 : Colors.red.shade50,
                      child: Text(
                        pago.metodoPago == 'EFECTIVO' ? 'Pendiente (Efectivo)' : 'Pendiente',
                        style: TextStyle(
                          color: pago.metodoPago == 'EFECTIVO' ? Colors.amber.shade900 : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Monto: ${pago.moneda} ${pago.monto.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Vence el: ${pago.fechaVencimiento}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              if (!isCompleted && !isRevision) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ShadButton.outline(
                        size: ShadButtonSize.sm,
                        onPressed: () => onStripePayment(pago),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.credit_card, size: 14),
                            SizedBox(width: 4),
                            Text('Pagar Tarjeta'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ShadButton.outline(
                        size: ShadButtonSize.sm,
                        onPressed: isUploading ? null : () => onUploadReceipt(pago),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file, size: 14),
                            SizedBox(width: 4),
                            Text('Comprobante'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
