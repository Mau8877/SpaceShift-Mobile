import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:space_shift/features/home/presentation/providers/property_filters_provider.dart';

class PriceDialog extends ConsumerStatefulWidget {
  final double? initialMin;
  final double? initialMax;

  const PriceDialog({super.key, this.initialMin, this.initialMax});

  @override
  ConsumerState<PriceDialog> createState() => _PriceDialogState();

  static void show(BuildContext context, double? min, double? max) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PriceDialog(initialMin: min, initialMax: max),
    );
  }
}

class _PriceDialogState extends ConsumerState<PriceDialog> {
  late double _min;
  late double _max;
  final double _absMax = 300000; // Valor máximo para el slider

  @override
  void initState() {
    super.initState();
    _min = widget.initialMin ?? 0;
    _max = widget.initialMax ?? _absMax;
  }

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: bottomInset + 24,
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
                    'Rango de precio',
                    style: ShadTheme.of(context).textTheme.h3.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          RangeSlider(
                            values: RangeValues(_min, _max),
                            min: 0,
                            max: _absMax,
                            divisions: 30,
                            activeColor: colors.primary,
                            inactiveColor: colors.muted,
                            onChanged: (values) {
                              setState(() {
                                _min = values.start;
                                _max = values.end;
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('0', style: TextStyle(color: colors.mutedForeground, fontSize: 12)),
                                Text('150k', style: TextStyle(color: colors.mutedForeground, fontSize: 12)),
                                Text('300k+', style: TextStyle(color: colors.mutedForeground, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: _PriceBox(
                                  label: 'MÍNIMO',
                                  value: '\$ ${_min.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _PriceBox(
                                  label: 'MÁXIMO',
                                  value: _max >= _absMax 
                                    ? 'Sin límite' 
                                    : '\$ ${_max.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.ghost(
                          onPressed: () {
                            ref.read(propertyFiltersControllerProvider.notifier).updatePriceRange(null, null);
                            Navigator.pop(context);
                          },
                          child: const Text('Limpiar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShadButton(
                          onPressed: () {
                            ref.read(propertyFiltersControllerProvider.notifier).updatePriceRange(_min, _max >= _absMax ? null : _max);
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

class _PriceBox extends StatelessWidget {
  final String label;
  final String value;

  const _PriceBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.muted.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.mutedForeground),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
