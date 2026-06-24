import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/video_upload_controller.dart';
import '../../data/video_repository.dart';
import '../../../tokens/presentation/providers/tokens_controller.dart';

Future<void> showVideoUploadFlow(BuildContext context, WidgetRef ref, String idPublicacion) async {
  // 1. Pick Video File
  final result = await FilePicker.pickFiles(type: FileType.video);
  if (result == null || result.files.isEmpty) return;

  final file = File(result.files.first.path!);

  if (!context.mounted) return;

  // Show loading indicator while parsing video
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (c) => const Center(child: CircularProgressIndicator()),
  );

  // 2. Get Video Duration
  final videoPlayerController = VideoPlayerController.file(file);
  await videoPlayerController.initialize();
  final duration = videoPlayerController.value.duration;
  final duracionSegundos = duration.inSeconds;
  await videoPlayerController.dispose();

  if (!context.mounted) return;
  Navigator.of(context).pop(); // Close loading

  // 3. Show Config / Quote Dialog
  showShadDialog(
    context: context,
    builder: (context) => _QuoteVideoDialog(
      file: file,
      duracionSegundos: duracionSegundos,
      idPublicacion: idPublicacion,
    ),
  );
}

class _QuoteVideoDialog extends ConsumerStatefulWidget {
  final File file;
  final int duracionSegundos;
  final String idPublicacion;

  const _QuoteVideoDialog({
    required this.file,
    required this.duracionSegundos,
    required this.idPublicacion,
  });

  @override
  ConsumerState<_QuoteVideoDialog> createState() => _QuoteVideoDialogState();
}

class _QuoteVideoDialogState extends ConsumerState<_QuoteVideoDialog> {
  String _formato = 'SOG';
  bool _isQuoting = true;
  int? _costoTokens;
  bool? _saldoSuficiente;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cotizar();
  }

  Future<void> _cotizar() async {
    setState(() {
      _isQuoting = true;
      _error = null;
    });

    try {
      final repository = ref.read(videoRepositoryProvider);
      final response = await repository.cotizar(widget.duracionSegundos, _formato);
      
      setState(() {
        _costoTokens = response['costoCreditos'];
        _saldoSuficiente = response['saldoSuficiente'];
        _isQuoting = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isQuoting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Generar Modelo 3D'),
      description: const Text('Configura el formato y revisa el costo estimado de la generación.'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('Formato de Salida:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ShadSelect<String>(
            initialValue: _formato,
            options: const [
              ShadOption(value: 'SOG', child: Text('SOG (Recomendado)')),
              ShadOption(value: 'SPLAT', child: Text('SPLAT (Mayor Costo)')),
            ],
            onChanged: (val) {
              if (val != null && val != _formato) {
                setState(() => _formato = val);
                _cotizar();
              }
            },
            selectedOptionBuilder: (context, value) => Text(value),
          ),
          const SizedBox(height: 16),
          if (_isQuoting)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Text('Error: $_error', style: const TextStyle(color: Colors.red))
          else ...[
              Text('Duración: ${widget.duracionSegundos}s'),
              const SizedBox(height: 8),
              Text(
                'Costo Estimado: $_costoTokens tokens',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (_saldoSuficiente == false)
                const Text('Saldo Insuficiente. Adquiere más tokens para continuar.',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
            ],
        ],
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ShadButton(
          onPressed: (_isQuoting || _saldoSuficiente != true)
              ? null
              : () {
                  // Iniciar la subida en background
                  ref.read(videoUploadControllerProvider.notifier).iniciarSubida(
                        idPublicacion: widget.idPublicacion,
                        file: widget.file,
                        duracionSegundos: widget.duracionSegundos,
                        formato: _formato,
                      );
                  
                  // Refrescar saldo del usuario asumiendo que se cobraron
                  ref.read(saldoControllerProvider.notifier).refrescarSaldo();
                  
                  Navigator.of(context).pop();
                  ShadToaster.of(context).show(
                    const ShadToast(description: Text('Subida iniciada en segundo plano')),
                  );
                },
          child: const Text('Subir y Generar'),
        ),
      ],
    );
  }
}
