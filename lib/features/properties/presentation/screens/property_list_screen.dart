import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PropertyListScreen extends StatelessWidget {
  const PropertyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar Propiedades')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏡 Listado de Departamentos (Público)'),
            const SizedBox(height: 20),
            ShadButton.outline(
              onPressed: () {
                // Forzamos el login si quiere realizar una acción protegida
                context.push('/login');
              },
              child: const Text('Firmar Contrato (Requiere Login)'),
            ),
          ],
        ),
      ),
    );
  }
}
