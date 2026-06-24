import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/contratos_provider.dart';
import '../../domain/contrato_model.dart';

class ContratosListScreen extends ConsumerWidget {
  const ContratosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Contratos'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Como Cliente', icon: Icon(Icons.person_outline)),
              Tab(text: 'Como Propietario', icon: Icon(Icons.business_center_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ContratosListTab(esPropietario: false),
            _ContratosListTab(esPropietario: true),
          ],
        ),
      ),
    );
  }
}

class _ContratosListTab extends ConsumerWidget {
  final bool esPropietario;

  const _ContratosListTab({required this.esPropietario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = esPropietario ? contratosPropietarioProvider : contratosClienteProvider;
    final contratosAsync = ref.watch(provider);

    return contratosAsync.when(
      data: (contratos) {
        if (contratos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  esPropietario
                      ? 'No tienes contratos como propietario'
                      : 'No tienes contratos como cliente',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(provider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contratos.length,
            itemBuilder: (context, index) {
              final contrato = contratos[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildContratoCard(context, contrato, ref),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildContratoCard(BuildContext context, Contrato contrato, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final statusColor = _getStatusColor(contrato.estadoContrato);

    return GestureDetector(
      onTap: () {
        context.push('/contrato_detail', extra: contrato.id);
      },
      child: ShadCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    contrato.inmuebleTitulo,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Código: ${contrato.codigo}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${_formatDate(contrato.fechaInicio)} - ${_formatDate(contrato.fechaFin)}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.nightlight_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${contrato.noches} noches',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      esPropietario ? 'Inquilino:' : 'Propietario:',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      esPropietario ? contrato.clienteNombre : contrato.propietarioNombre,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Monto Acordado:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '${contrato.moneda} ${contrato.montoAcordado.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
