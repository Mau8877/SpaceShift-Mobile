import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../providers/perfil_controller.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../tokens/presentation/providers/tokens_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(perfilControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: perfilAsync.when(
        data: (perfil) {
          if (perfil == null) {
            return const Center(child: Text('No se pudo cargar el perfil'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: perfil.fotoUrl != null
                      ? NetworkImage(perfil.fotoUrl!)
                      : null,
                  child: perfil.fotoUrl == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  '${perfil.nombre} ${perfil.apellido}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  perfil.correo,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                if (perfil.tipoPerfil != null)
                  Chip(
                    label: Text(perfil.tipoPerfil!),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                const SizedBox(height: 32),
                _buildInfoSection(
                  context,
                  'Información de Contacto',
                  [
                    _buildInfoItem(Icons.phone, 'Teléfono', perfil.telefono ?? 'No registrado'),
                    _buildInfoItem(Icons.description, 'Descripción', perfil.descripcion ?? 'Sin descripción'),
                  ],
                ),
                const SizedBox(height: 24),
                _buildWalletSection(context, ref),
                const SizedBox(height: 24),
                ShadButton.outline(
                  width: double.infinity,
                  onPressed: () => context.push('/mis_inmuebles'),
                  child: const Text('Mis Inmuebles'),
                ),
                const SizedBox(height: 12),
                ShadButton.outline(
                  width: double.infinity,
                  onPressed: () => context.push('/contratos'),
                  child: const Text('Mis Contratos'),
                ),
                const SizedBox(height: 12),
                ShadButton(
                  width: double.infinity,
                  onPressed: () => context.push('/profile-edit'),
                  child: const Text('Editar Perfil'),
                ),
                const SizedBox(height: 40),
                ShadButton.destructive(
                  width: double.infinity,
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ShadButton(
                onPressed: () => ref.invalidate(perfilControllerProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildWalletSection(BuildContext context, WidgetRef ref) {
    final saldoAsync = ref.watch(saldoControllerProvider);
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monedero de Créditos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.token,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saldo Disponible',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        saldoAsync.when(
                          data: (saldo) => Text(
                            '${saldo?.saldoCreditos ?? 0} SST',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          loading: () => const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (_, __) => const Text(
                            '0 SST',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ShadButton.outline(
                    onPressed: () => context.push('/buy-credits'),
                    size: ShadButtonSize.sm,
                    child: const Text('Comprar SST'),
                  ),
                ],
              ),
              const Divider(height: 24),
              GestureDetector(
                onTap: () => context.push('/credit-history'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ver historial de transacciones',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}