import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RentalSummaryCard extends StatelessWidget {
  final bool isRental;
  final String moneda;
  final double precioBase;
  final int nights;
  final int dispositivosCount;
  final double totalDevices;
  final double totalFinal;
  final bool isLoading;
  final VoidCallback onSubmit;

  const RentalSummaryCard({
    super.key,
    required this.isRental,
    required this.moneda,
    required this.precioBase,
    required this.nights,
    required this.dispositivosCount,
    required this.totalDevices,
    required this.totalFinal,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del Contrato',
            style: theme.textTheme.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          if (isRental) ...[
            _summaryItem('Precio por noche', '$moneda ${precioBase.toStringAsFixed(0)}'),
            _summaryItem('Noches de estancia', '$nights noches'),
            _summaryItem('Monto base inmueble', '$moneda ${(precioBase * nights).toStringAsFixed(0)}'),
            if (dispositivosCount > 0)
              _summaryItem(
                'Dispositivos rentados ($dispositivosCount)',
                '$moneda ${totalDevices.toStringAsFixed(0)}',
              ),
            const Divider(height: 24),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Final',
                style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '$moneda ${totalFinal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ShadButton(
            width: double.infinity,
            size: ShadButtonSize.lg,
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Enviar Propuesta de Contrato'),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
