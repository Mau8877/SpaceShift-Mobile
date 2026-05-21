import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../domain/register_request.dart';
import '../providers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  
  TipoPerfil _tipoPerfil = TipoPerfil.personal;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nombreController.text.isEmpty ||
        _apellidoController.text.isEmpty) {
      _showToast('Todos los campos son obligatorios', isError: true);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showToast('Las contraseñas no coinciden', isError: true);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showToast('La contraseña debe tener al menos 6 caracteres', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    
    final request = RegisterRequest(
      correo: _emailController.text.trim(),
      password: _passwordController.text,
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      tipoPerfil: _tipoPerfil.value,
    );
    
    final success = await ref
        .read(authControllerProvider.notifier)
        .register(request);
    
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      _showToast('¡Registro exitoso!');
      context.go('/home');
    } else {
      final errorMensaje = ref.read(authControllerProvider).error?.toString() ?? 'Error en el registro';
      _showToast(errorMensaje, isError: true);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ShadToaster.of(context).show(
      isError
          ? ShadToast.destructive(title: Text(message))
          : ShadToast(title: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Personal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ShadInput(
              controller: _nombreController,
              placeholder: const Text('Nombre'),
            ),
            const SizedBox(height: 12),
            ShadInput(
              controller: _apellidoController,
              placeholder: const Text('Apellido'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tipo de Perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<TipoPerfil>(
              value: _tipoPerfil,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: TipoPerfil.values.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _tipoPerfil = value);
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Credenciales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ShadInput(
              controller: _emailController,
              placeholder: const Text('Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                ShadInput(
                  controller: _passwordController,
                  placeholder: const Text('Contraseña'),
                  obscureText: _obscurePassword,
                ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                ShadInput(
                  controller: _confirmPasswordController,
                  placeholder: const Text('Confirmar contraseña'),
                  obscureText: _obscureConfirmPassword,
                ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ShadButton(
              width: double.infinity,
              onPressed: _isLoading ? null : _register,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear cuenta'),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}