import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../providers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ShadInput(
              controller: _emailController,
              placeholder: const Text('Tu correo electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            ShadInput(
              controller: _passwordController,
              placeholder: const Text('Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/password-recovery'),
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
            const SizedBox(height: 16),
            ShadButton(
              width: double.infinity,
              onPressed: authState.isLoading
                  ? null
                  : () async {
                      if (_emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        ShadToaster.of(context).show(
                          const ShadToast.destructive(
                            title: Text('Campos vacíos'),
                            description: Text(
                              'Por favor, ingresa tu correo y contraseña.',
                            ),
                          ),
                        );
                        return;
                      }

                      final success = await ref
                          .read(authControllerProvider.notifier)
                          .login(
                            _emailController.text.trim(),
                            _passwordController.text,
                          );

                      if (!context.mounted) return;

                      if (success) {
                        ShadToaster.of(context).show(
                          const ShadToast(
                            title: Text('¡Bienvenido!'),
                            description: Text(
                              'Has iniciado sesión correctamente.',
                            ),
                          ),
                        );
                        context.go('/home');
                      } else {
                        final errorMensaje =
                            ref
                                .read(authControllerProvider)
                                .error
                                ?.toString() ??
                            'Credenciales incorrectas.';

                        ShadToaster.of(context).show(
                          ShadToast.destructive(
                            title: const Text('Error de Autenticación'),
                            description: Text(errorMensaje),
                          ),
                        );
                      }
                    },
              child: authState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
