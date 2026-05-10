import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/network/dio_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Avatar y Nombre (Simulado)
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mi Perfil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            // Opciones de menú
            _buildProfileOption(
              context,
              icon: Icons.house_outlined,
              title: 'Mis Inmuebles',
              subtitle: 'Gestiona tus publicaciones y ventas',
              onTap: () => context.push('/mis_inmuebles'),
            ),
            
            _buildProfileOption(
              context,
              icon: Icons.notifications_none_outlined,
              title: 'Notificaciones',
              subtitle: 'Configura tus alertas',
              onTap: () {},
            ),
            
            _buildProfileOption(
              context,
              icon: Icons.settings_outlined,
              title: 'Ajustes',
              subtitle: 'Privacidad y cuenta',
              onTap: () {},
            ),
            
            const SizedBox(height: 40),
            
            // Botón de Cerrar Sesión
            SizedBox(
              width: double.infinity,
              child: ShadButton.destructive(
                onPressed: () async {
                  await ref.read(tokenStorageProvider).clearToken();
                  if (context.mounted) context.go('/login');
                },
                child: const Text('Cerrar Sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ShadCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon, color: ShadTheme.of(context).colorScheme.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
