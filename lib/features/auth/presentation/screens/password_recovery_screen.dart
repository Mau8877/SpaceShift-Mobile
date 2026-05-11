import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../providers/auth_controller.dart';

class PasswordRecoveryScreen extends ConsumerStatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  ConsumerState<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends ConsumerState<PasswordRecoveryScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  
  RecoveryStep _step = RecoveryStep.correo;
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _codeLength = 0;
  int _passwordLength = 0;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onCodeChanged() {
    setState(() {
      _codeLength = _codeController.text.length;
    });
  }

  void _onPasswordChanged() {
    setState(() {
      _passwordLength = _passwordController.text.length;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_emailController.text.isEmpty) {
      _showToast('Ingresa tu correo electrónico', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await ref
        .read(authControllerProvider.notifier)
        .solicitarRecuperacion(_emailController.text.trim());
    
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      _showToast('Código enviado a tu correo');
      setState(() => _step = RecoveryStep.codigo);
    } else {
      _showToast('Error al enviar el código', isError: true);
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      _showToast('Ingresa el código de verificación', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await ref
        .read(authControllerProvider.notifier)
        .validarCodigo(_emailController.text.trim(), _codeController.text);
    
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      _showToast('Código verificado');
      setState(() => _step = RecoveryStep.nuevaPassword);
    } else {
      _showToast('Código inválido o expirado', isError: true);
    }
  }

  Future<void> _changePassword() async {
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      _showToast('La contraseña debe tener al menos 6 caracteres', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await ref
        .read(authControllerProvider.notifier)
        .cambiarPassword(
          _emailController.text.trim(),
          _codeController.text,
          _passwordController.text,
        );
    
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      _showToast('Contraseña actualizada correctamente');
      context.go('/login');
    } else {
      _showToast('Error al cambiar la contraseña', isError: true);
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
        title: const Text('Recuperar Contraseña'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _step == RecoveryStep.correo
            ? _buildCorreoStep()
            : _step == RecoveryStep.codigo
                ? _buildCodigoStep()
                : _buildNuevaPasswordStep(),
      ),
    );
  }

  Widget _buildCorreoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingresa tu correo electrónico',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Te enviaremos un código de verificación.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ShadInput(
          controller: _emailController,
          placeholder: const Text('correo@ejemplo.com'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        ShadButton(
          width: double.infinity,
          onPressed: _isLoading ? null : _sendCode,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar código'),
        ),
      ],
    );
  }

  Widget _buildCodigoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verifica tu código',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'El código fue enviado a ${_emailController.text}',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ShadInput(
          controller: _codeController,
          placeholder: const Text('Código de 6 dígitos'),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ShadButton(
          width: double.infinity,
          onPressed: _isLoading || _codeLength < 6
              ? null
              : _verifyCode,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verificar código'),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _step = RecoveryStep.correo),
            child: const Text('Volver'),
          ),
        ),
      ],
    );
  }

  Widget _buildNuevaPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 48),
        const SizedBox(height: 16),
        const Text(
          'Código verificado',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa tu nueva contraseña.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Stack(
          children: [
            ShadInput(
              controller: _passwordController,
              placeholder: const Text('Nueva contraseña'),
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
        const SizedBox(height: 24),
        ShadButton(
          width: double.infinity,
          onPressed: _isLoading || _passwordLength < 6
              ? null
              : _changePassword,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Cambiar contraseña'),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _step = RecoveryStep.correo),
            child: const Text('Volver'),
          ),
        ),
      ],
    );
  }
}