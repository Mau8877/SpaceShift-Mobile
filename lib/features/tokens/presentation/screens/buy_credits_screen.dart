import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../data/tokens_repository.dart';
import '../../domain/paquete_model.dart';
import '../providers/tokens_controller.dart';

class BuyCreditsScreen extends ConsumerStatefulWidget {
  const BuyCreditsScreen({super.key});

  @override
  ConsumerState<BuyCreditsScreen> createState() => _BuyCreditsScreenState();
}

class _BuyCreditsScreenState extends ConsumerState<BuyCreditsScreen> {
  String? _loadingPaqueteId;

  Future<void> _iniciarPago(BuildContext context, PaqueteCredito paquete) async {
    setState(() {
      _loadingPaqueteId = paquete.id;
    });

    try {
      final repository = ref.read(tokensRepositoryProvider);
      debugPrint("[DEBUG - Stripe] Creando sesión de cobro para el paquete ${paquete.nombrePaquete}");
      
      // 1. Obtener la sesión de Stripe desde el backend
      final checkoutUrl = await repository.comprarPaquete(paquete.id);
      
      if (checkoutUrl.isEmpty) {
        throw Exception("El backend no retornó ninguna URL de sesión válida.");
      }

      if (!context.mounted) return;

      // 2. Navegar a la WebView de pago seguro y esperar el resultado
      final result = await context.push<bool>('/payment-webview', extra: checkoutUrl);

      if (!context.mounted) return;

      // 3. Procesar el resultado del pago
      if (result == true) {
        // Recargar el saldo actual del usuario reactivamente
        ref.read(saldoControllerProvider.notifier).refrescarSaldo();
        
        ShadToaster.of(context).show(
          ShadToast(
            title: const Text('¡Compra Completada!'),
            description: Text('Se acreditaron exitosamente ${paquete.creditosPaquetes} SST a tu cuenta.'),
          ),
        );
      } else {
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            title: Text('Pago Cancelado'),
            description: Text('El proceso de compra en Stripe fue cancelado por el usuario.'),
          ),
        );
      }
    } catch (e) {
      debugPrint("[ERROR - Stripe] Ocurrió un error en el flujo de Stripe: $e");
      if (context.mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error en el Pago'),
            description: Text('No pudimos procesar tu solicitud: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingPaqueteId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final saldoAsync = ref.watch(saldoControllerProvider);
    final paquetesAsync = ref.watch(paquetesCreditoProvider);
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprar Créditos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(saldoControllerProvider);
          ref.invalidate(paquetesCreditoProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tarjeta Premium del Saldo Actual
              _buildSaldoCard(context, saldoAsync, theme),
              const SizedBox(height: 28),

              // 2. Título Sección Catálogo
              Text(
                'Adquirir Paquetes de Créditos',
                style: theme.textTheme.large.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Usa tus créditos para publicar inmuebles y destacar tus anuncios en la plataforma.',
                style: theme.textTheme.muted.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 16),

              // 3. Catálogo de Paquetes
              paquetesAsync.when(
                data: (paquetes) => _buildPaquetesGrid(context, paquetes, theme),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text('Error al cargar paquetes: $err'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaldoCard(
      BuildContext context, AsyncValue<dynamic> saldoAsync, ShadThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SALDO DISPONIBLE',
                style: TextStyle(
                  color: theme.colorScheme.primaryForeground.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              Icon(
                Icons.token,
                color: theme.colorScheme.primaryForeground,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          saldoAsync.when(
            data: (saldo) => Text(
              '${saldo?.saldoCreditos ?? 0} SST',
              style: TextStyle(
                color: theme.colorScheme.primaryForeground,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            loading: () => SizedBox(
              height: 38,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primaryForeground,
                ),
              ),
            ),
            error: (_, __) => Text(
              '0 SST',
              style: TextStyle(
                color: theme.colorScheme.primaryForeground,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'SpaceShift Tokens (SST)',
            style: TextStyle(
              color: theme.colorScheme.primaryForeground.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaquetesGrid(
      BuildContext context, List<PaqueteCredito> paquetes, ShadThemeData theme) {
    if (paquetes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay paquetes disponibles en este momento.'),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: paquetes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final paquete = paquetes[index];
        final isThisLoading = _loadingPaqueteId == paquete.id;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paquete.nombrePaquete,
                      style: theme.textTheme.large.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (paquete.descripcion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        paquete.descripcion!,
                        style: theme.textTheme.muted.copyWith(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${paquete.creditosPaquetes} SST',
                        style: TextStyle(
                          color: theme.colorScheme.secondaryForeground,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Bs. ${paquete.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShadButton(
                    onPressed: isThisLoading ? null : () => _iniciarPago(context, paquete),
                    size: ShadButtonSize.sm,
                    child: isThisLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Comprar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
