import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../domain/perfil_model.dart';
import '../providers/perfil_controller.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _initControllers(Perfil perfil) {
    if (!_isInitialized) {
      _nombreController.text = perfil.nombre;
      _apellidoController.text = perfil.apellido;
      _telefonoController.text = perfil.telefono ?? '';
      _descripcionController.text = perfil.descripcion ?? '';
      _isInitialized = true;
    }
  }

  Future<void> _saveProfile(Perfil perfil) async {
    final request = PerfilPatchRequestFull(
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
    );

    setState(() => _isLoading = true);
    
    final success = await ref
        .read(perfilControllerProvider.notifier)
        .actualizarPerfil(request);
    
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ShadToaster.of(context).show(
        const ShadToast(
          title: Text('Perfil actualizado'),
          description: Text('Tus cambios han sido guardados.'),
        ),
      );
      context.pop();
    } else {
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Error'),
          description: Text(ref.read(perfilControllerProvider).error?.toString() ?? 'No se pudo guardar'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          perfilAsync.when(
            data: (perfil) => perfil != null
                ? IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    onPressed: _isLoading ? null : () => _saveProfile(perfil),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: perfilAsync.when(
        data: (perfil) {
          if (perfil == null) {
            return const Center(child: Text('No se pudo cargar el perfil'));
          }
          
          _initControllers(perfil);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: perfil.fotoUrl != null
                        ? NetworkImage(perfil.fotoUrl!)
                        : null,
                    child: perfil.fotoUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
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
                  'Información de Contacto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ShadInput(
                  controller: _telefonoController,
                  placeholder: const Text('Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Descripción',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descripcionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Cuéntanos sobre ti...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ShadButton(
                  width: double.infinity,
                  onPressed: _isLoading ? null : () => _saveProfile(perfil),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar cambios'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}