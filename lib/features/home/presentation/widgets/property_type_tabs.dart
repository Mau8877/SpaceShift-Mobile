import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:space_shift/features/home/presentation/providers/property_filters_provider.dart';

class PropertyTypeTabs extends ConsumerWidget {
  const PropertyTypeTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(propertyFiltersControllerProvider);
    final colors = ShadTheme.of(context).colorScheme;

    return Container(
      // Eliminamos el padding horizontal para que las pestañas lleguen al borde
      decoration: BoxDecoration(
        color: colors.muted.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: colors.border.withOpacity(0.5)),
          left: BorderSide(color: colors.border.withOpacity(0.5)),
          right: BorderSide(color: colors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'VENTA',
            icon: Icons.home_outlined,
            isActive: filters.transactionType == 'VENTA',
            isFirst: true, // Para redondear la esquina izquierda
            onTap: () => ref.read(propertyFiltersControllerProvider.notifier).updateTransactionType('VENTA'),
          ),
          _TabItem(
            label: 'ALQUILER',
            icon: Icons.key_outlined,
            isActive: filters.transactionType == 'ALQUILER',
            isLast: true, // Para redondear la esquina derecha
            onTap: () => ref.read(propertyFiltersControllerProvider.notifier).updateTransactionType('ALQUILER'),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
              topRight: isLast ? const Radius.circular(16) : Radius.zero,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? colors.primaryForeground : colors.mutedForeground,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? colors.primaryForeground : colors.mutedForeground,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
