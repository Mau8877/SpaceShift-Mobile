import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../domain/contrato_model.dart';
import '../../domain/pago_contrato_model.dart';
import '../providers/contratos_provider.dart';
import 'contract_details_card.dart';
import 'payment_schedule_list.dart';

// Layout for Payment and Signature phase after contract is created
class ContractPaymentAndSignatureLayout extends ConsumerStatefulWidget {
  final Contrato contrato;
  final VoidCallback onBack;

  const ContractPaymentAndSignatureLayout({
    super.key,
    required this.contrato,
    required this.onBack,
  });

  @override
  ConsumerState<ContractPaymentAndSignatureLayout> createState() =>
      _ContractPaymentAndSignatureLayoutState();
}

class _ContractPaymentAndSignatureLayoutState
    extends ConsumerState<ContractPaymentAndSignatureLayout> {
  bool _isUploading = false;
  bool _isSigning = false;

  Future<void> _handleStripePayment(PagoContrato pago) async {
    final notifier = ref.read(contratoControllerProvider.notifier);
    final originUrl = "http://localhost:3000/profile?success=true"; // redirection format

    ShadToaster.of(context).show(
      const ShadToast(description: Text('Generando pasarela de pago Stripe...')),
    );

    final checkoutUrl = await notifier.generarSesionPagoStripe(pago.id, originUrl);

    if (checkoutUrl != null) {
      // Abre WebView en una nueva pantalla del router
      final paymentSuccess = await context.push('/payment-webview', extra: checkoutUrl);

      if (paymentSuccess == true) {
        ShadToaster.of(context).show(
          const ShadToast(description: Text('¡Pago confirmado correctamente por Stripe!')),
        );
        ref.invalidate(pagosDeContratoProvider(widget.contrato.id));
      } else {
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            description: Text('El pago fue cancelado o no se completó.'),
          ),
        );
      }
    } else {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          description: Text('Error al conectar con la pasarela de Stripe.'),
        ),
      );
    }
  }

  Future<void> _handleUploadReceipt(PagoContrato pago) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isUploading = true);

    ShadToaster.of(context).show(
      const ShadToast(description: Text('Subiendo comprobante de transferencia...')),
    );

    final success = await ref
        .read(contratoControllerProvider.notifier)
        .subirComprobantePago(pago.id, image.path, widget.contrato.id);

    setState(() => _isUploading = false);

    if (success) {
      ShadToaster.of(context).show(
        const ShadToast(
          description: Text('Comprobante subido. Pendiente de verificación por el propietario.'),
        ),
      );
    } else {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          description: Text('Error al subir el comprobante.'),
        ),
      );
    }
  }

  Future<void> _handleSignContract() async {
    setState(() => _isSigning = true);

    ShadToaster.of(context).show(
      const ShadToast(description: Text('Firmando contrato digitalmente y en Blockchain...')),
    );

    final success = await ref
        .read(contratoControllerProvider.notifier)
        .firmarContrato(widget.contrato.id);

    setState(() => _isSigning = false);

    if (success) {
      ShadToaster.of(context).show(
        const ShadToast(description: Text('¡Contrato firmado y activado correctamente!')),
      );
      // Redirigir a detalle del contrato
      context.go('/contratos'); // o /contrato_detail con widget.contrato.id como extra
    } else {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          description: Text('Error al realizar la firma.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pagosAsync = ref.watch(pagosDeContratoProvider(widget.contrato.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago y Firma de Contrato'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contract header
              ContractDetailsCard(contrato: widget.contrato),
              const SizedBox(height: 24),

              // Section 1: Payment Schedule
              Text(
                '1. Pago Inicial Programado',
                style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              pagosAsync.when(
                data: (pagos) {
                  if (pagos.isEmpty) {
                    return const Text('No hay pagos programados para este contrato.');
                  }
                  return PaymentScheduleList(
                    pagos: pagos,
                    isUploading: _isUploading,
                    onStripePayment: (pago) => _handleStripePayment(pago),
                    onUploadReceipt: (pago) => _handleUploadReceipt(pago),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Text('Error al cargar cronograma de pagos: $err'),
              ),
              const SizedBox(height: 28),

              // Section 2: Signature
              Text(
                '2. Firmar Contrato',
                style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              pagosAsync.when(
                data: (pagos) {
                  final needsDigitalPaymentBeforeSignature = pagos.any((p) =>
                      p.metodoPago != 'EFECTIVO' &&
                      p.estadoPago != 'COMPLETADO');

                  if (needsDigitalPaymentBeforeSignature) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50.withOpacity(isDark ? 0.1 : 0.8),
                        border: Border.all(color: Colors.amber.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Debes completar el pago inicial programado arriba para habilitar la firma digital de este contrato.',
                              style: TextStyle(
                                color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final allEfectivo = pagos.every((p) => p.metodoPago == 'EFECTIVO');

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50.withOpacity(isDark ? 0.1 : 0.8),
                          border: Border.all(color: Colors.green.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                allEfectivo
                                    ? 'Pago en efectivo acordado. Ya puedes proceder a firmar el contrato.'
                                    : '¡Pago confirmado! Ya puedes proceder a firmar el contrato.',
                                style: TextStyle(
                                  color: isDark ? Colors.green.shade200 : Colors.green.shade900,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ShadButton(
                        width: double.infinity,
                        size: ShadButtonSize.lg,
                        onPressed: _isSigning ? null : _handleSignContract,
                        child: _isSigning
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.border_color),
                                  SizedBox(width: 8),
                                  Text('Firmar Contrato Digitalmente'),
                                ],
                              ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(),
                error: (e, s) => const SizedBox(),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
