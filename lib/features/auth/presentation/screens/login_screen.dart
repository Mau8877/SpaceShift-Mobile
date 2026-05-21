import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../providers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D12) : const Color(0xFFFAFAFB),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 32,
                vertical: MediaQuery.of(context).size.height * 0.08,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(isDark),
                  const SizedBox(height: 48),
                  _buildWelcomeSection(isDark),
                  const SizedBox(height: 40),
                  _buildInputFields(isDark, theme),
                  const SizedBox(height: 16),
                  _buildForgotPassword(isDark),
                  const SizedBox(height: 32),
                  _buildLoginButton(authState, isDark),
                  const SizedBox(height: 32),
                  _buildDivider(isDark),
                  const SizedBox(height: 32),
                  _buildRegisterLink(isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2F6EB5),
            const Color(0xFF1E4E8C),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F6EB5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.home_work_rounded,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildWelcomeSection(bool isDark) {
    return Column(
      children: [
        Text(
          'SpaceShift',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF1A1A23),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sesión para continuar',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF6B6B80),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields(bool isDark, ThemeData theme) {
    return Column(
      children: [
        _MinimalInputField(
          controller: _emailController,
          icon: Icons.mail_outline_rounded,
          hint: 'Correo electrónico',
          keyboardType: TextInputType.emailAddress,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _MinimalInputField(
          controller: _passwordController,
          icon: Icons.lock_outline_rounded,
          hint: 'Contraseña',
          obscureText: _obscurePassword,
          isDark: isDark,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: isDark ? Colors.white.withOpacity(0.4) : const Color(0xFF6B6B80),
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword(bool isDark) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => context.push('/password-recovery'),
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF2F6EB5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(AsyncValue<void> authState, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ShadButton(
        onPressed: authState.isLoading ? null : _handleLogin,
        child: authState.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Row(
      children: [
        Expanded(child: Divider(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE8E8EC))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'o',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white.withOpacity(0.4) : const Color(0xFF6B6B80),
            ),
          ),
        ),
        Expanded(child: Divider(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE8E8EC))),
      ],
    );
  }

  Widget _buildRegisterLink(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta?',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF6B6B80),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => context.push('/register'),
          child: const Text(
            'Regístrate',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F6EB5),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title: Text('Campos vacíos'),
          description: Text('Por favor, ingresa tu correo y contraseña.'),
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

    if (!mounted) return;

    if (success) {
      ShadToaster.of(context).show(
        const ShadToast(
          title: Text('¡Bienvenido!'),
          description: Text('Has iniciado sesión correctamente.'),
        ),
      );
      context.go('/home');
    } else {
      final errorMensaje =
          ref.read(authControllerProvider).error?.toString() ??
          'Credenciales incorrectas.';

      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Error de Autenticación'),
          description: Text(errorMensaje),
        ),
      );
    }
  }
}

class _MinimalInputField extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool obscureText;
  final bool isDark;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _MinimalInputField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.obscureText = false,
    required this.isDark,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  State<_MinimalInputField> createState() => _MinimalInputFieldState();
}

class _MinimalInputFieldState extends State<_MinimalInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _isFocused 
        ? const Color(0xFF2F6EB5) 
        : widget.isDark 
            ? Colors.white.withOpacity(0.1) 
            : const Color(0xFFE8E8EC);

    final bgColor = widget.isDark 
        ? Colors.white.withOpacity(0.04) 
        : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: _isFocused ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        style: TextStyle(
          fontSize: 15,
          color: widget.isDark ? Colors.white : const Color(0xFF1A1A23),
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            fontSize: 14,
            color: widget.isDark ? Colors.white.withOpacity(0.35) : const Color(0xFF6B6B80),
          ),
          prefixIcon: Icon(
            widget.icon,
            size: 20,
            color: _isFocused 
                ? const Color(0xFF2F6EB5) 
                : widget.isDark 
                    ? Colors.white.withOpacity(0.4) 
                    : const Color(0xFF6B6B80),
          ),
          suffixIcon: widget.suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}