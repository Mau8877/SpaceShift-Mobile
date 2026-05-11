import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:space_shift/features/home/presentation/providers/property_filters_provider.dart';

class LocationDialog extends ConsumerStatefulWidget {
  final String currentValue;

  const LocationDialog({super.key, required this.currentValue});

  @override
  ConsumerState<LocationDialog> createState() => _LocationDialogState();

  static void show(BuildContext context, String current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationDialog(currentValue: current),
    );
  }
}

class _LocationDialogState extends ConsumerState<LocationDialog> {
  late TextEditingController _controller;

  // Lista completa según tu captura
  final List<String> popularZones = [
    'Equipetrol Norte', 'Las Palmas', 'Zona Norte', 'Cala Cala', 'Quillacollo',
    'Zona Sur', '4to Anillo', 'Sacaba', 'Porongo', 'Warnes', 'El Prado',
    'Urubó', 'Pampa de la Isla', 'Remansos', 'Ciudad Nueva', 'Zona Este',
    'Equipetrol', 'Aranjuez', 'Obrajes', 'Plan 3000', 'Villa Primero de Mayo'
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              constraints: BoxConstraints(
                maxHeight: media.size.height * 0.85, // Un poco más alto para ver más zonas
              ),
              padding: EdgeInsets.only(
                bottom: bottomInset > 0 ? bottomInset + 16 : media.padding.bottom + 24,
                top: 12,
                left: 24,
                right: 24,
              ),
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
                    '¿A dónde vas?',
                    style: ShadTheme.of(context).textTheme.h3.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  ShadInput(
                    controller: _controller,
                    placeholder: const Text('Cala Cala, Equipetrol...'),
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.search, size: 20),
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Zonas populares',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // El Flexible asegura que la lista use el espacio disponible sin desbordar
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: popularZones.map((loc) {
                          final isSelected = _controller.text.toLowerCase() == loc.toLowerCase();
                          return GestureDetector(
                            onTap: () => setState(() => _controller.text = loc),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? colors.primary : colors.muted.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? colors.primary : colors.border.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                loc,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? colors.primaryForeground : colors.foreground,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.secondary(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShadButton(
                          onPressed: () {
                            ref.read(propertyFiltersControllerProvider.notifier).updateLocation(_controller.text);
                            Navigator.pop(context);
                          },
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
