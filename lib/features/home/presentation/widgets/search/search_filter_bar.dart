import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:space_shift/features/home/presentation/providers/property_filters_provider.dart';
import 'filter_item.dart';
import 'location_dialog.dart';
import 'property_type_dialog.dart';
import 'price_dialog.dart';

class SearchFilterBar extends ConsumerWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(propertyFiltersControllerProvider);
    final colors = ShadTheme.of(context).colorScheme;

    return Container(
      // Quitamos el padding para que se alinee con las pestañas de arriba
      decoration: BoxDecoration(
        color: colors.muted.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        decoration: BoxDecoration(
          color: colors.background,
          // Un radio menor para el interior para que el borde exterior se vea uniforme
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        child: Row(
          children: [
            Expanded(
              child: FilterItem(
                label: 'Ubicación',
                value: filters.location.isEmpty ? 'Destino' : filters.location,
                icon: Icons.location_on_rounded,
                onTap: () => LocationDialog.show(context, filters.location),
              ),
            ),
            Expanded(
              child: FilterItem(
                label: 'Tipo',
                value: _formatPropertyType(filters.propertyType),
                icon: Icons.home_rounded,
                onTap: () => PropertyTypeDialog.show(context, ref, filters.propertyType),
              ),
            ),
            Expanded(
              child: FilterItem(
                label: 'Precio',
                value: _formatPriceRange(filters.minPrice, filters.maxPrice),
                icon: Icons.payments_rounded,
                onTap: () => PriceDialog.show(context, filters.minPrice, filters.maxPrice),
              ),
            ),
            const SizedBox(width: 8),
            ShadButton(
              width: 44,
              height: 44,
              padding: EdgeInsets.zero,
              onPressed: () => FocusScope.of(context).unfocus(),
              child: const Icon(Icons.search, size: 20),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  String _formatPropertyType(String? type) {
    if (type == null) return 'Cualquier';
    return type.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatPriceRange(double? min, double? max) {
    String format(double value) => 
      value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    if (min == null && max == null) return 'Presup.';
    if (min != null && max != null) {
      if (max >= 300000) return '\$ ${format(min)}+';
      return '\$ ${format(min)}-${format(max)}';
    }
    if (min != null) return '\$ ${format(min)}+';
    if (max != null) return '<\$ ${format(max)}';
    return 'Presup.';
  }
}
