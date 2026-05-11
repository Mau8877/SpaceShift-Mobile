import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:space_shift/features/home/presentation/providers/property_filters_provider.dart';
import 'package:space_shift/features/properties/data/publicacion_repository.dart';

class PropertyTypeDialog extends ConsumerStatefulWidget {
  final String? initialType;
  final List<String> availableTypes;

  const PropertyTypeDialog({
    super.key, 
    this.initialType,
    required this.availableTypes,
  });

  @override
  ConsumerState<PropertyTypeDialog> createState() => _PropertyTypeDialogState();

  static void show(BuildContext context, WidgetRef ref, String? current) async {
    final repository = ref.read(publicacionRepositoryProvider);
    final types = await repository.getTiposInmueble();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PropertyTypeDialog(
        initialType: current,
        availableTypes: types,
      ),
    );
  }
}

class _PropertyTypeDialogState extends ConsumerState<PropertyTypeDialog> {
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = theme.colorScheme;
    final media = MediaQuery.of(context);

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: media.size.height * 0.8,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.mutedForeground.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tipo de inmueble',
                style: theme.textTheme.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _TypeItem(
                        label: 'Cualquier tipo',
                        icon: Icons.grid_view_rounded,
                        isSelected: _selectedType == null,
                        onTap: () => setState(() => _selectedType = null),
                      ),
                      const SizedBox(height: 8),
                      ...widget.availableTypes.map((type) {
                        final isSelected = _selectedType == type;
                        return _TypeItem(
                          label: _formatType(type),
                          icon: _getIconForType(type),
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedType = type),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              ShadButton(
                width: double.infinity,
                onPressed: () {
                  ref.read(propertyFiltersControllerProvider.notifier).updatePropertyType(_selectedType);
                  Navigator.pop(context);
                },
                child: const Text('Aplicar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatType(String type) {
    return type.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'CASA': return Icons.home_rounded;
      case 'DEPARTAMENTO': return Icons.apartment_rounded;
      case 'OFICINA': return Icons.business_rounded;
      case 'LOCAL_COMERCIAL': return Icons.shopping_bag_rounded;
      case 'TERRENO': return Icons.landscape_rounded;
      default: return Icons.home_work_rounded;
    }
  }
}

class _TypeItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary.withOpacity(0.1) : colors.muted.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon, 
                size: 20, 
                color: isSelected ? colors.primary : colors.mutedForeground
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colors.foreground : colors.mutedForeground,
                ),
              ),
            ),
            // Radio Button style exactly as in the screenshot
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colors.primary : colors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
