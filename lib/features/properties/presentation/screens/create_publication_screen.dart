import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../domain/inmueble.dart';
import '../../domain/publicacion.dart';
import '../../domain/ubicacion.dart';
import '../providers/create_publication_controller.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/jwt_utils.dart';

class CreatePublicationScreen extends ConsumerStatefulWidget {
  const CreatePublicationScreen({super.key});

  @override
  ConsumerState<CreatePublicationScreen> createState() => _CreatePublicationScreenState();
}

class _CreatePublicationScreenState extends ConsumerState<CreatePublicationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Inmueble fields
  double m2 = 0;
  int habitaciones = 0;
  int banos = 0;
  double precio = 0.0;
  String titulo = '';
  String descripcion = '';
  
  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(createPublicationControllerProvider);
    final isLoading = creationState.isLoading;

    // Shadcn UI Notification on error
    ref.listen(createPublicationControllerProvider, (previous, next) {
      if (next.hasError) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
             title: const Text('Error'),
             description: Text(next.error.toString()),
          )
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Publicación'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del Inmueble',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              ShadInputFormField(
                label: const Text('Título del Anuncio'),
                placeholder: const Text('Ej. Hermosa casa céntrica'),
                validator: (v) => v.isEmpty ? 'Requerido' : null,
                onSaved: (v) => titulo = v ?? '',
              ),
              const SizedBox(height: 16),

              ShadInputFormField(
                label: const Text('Descripción'),
                placeholder: const Text('Detalles sobre la propiedad...'),
                minLines: 3,
                maxLines: 5,
                validator: (v) => v.isEmpty ? 'Requerido' : null,
                onSaved: (v) => descripcion = v ?? '',
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ShadInputFormField(
                      label: const Text('M2 Construidos'),
                      keyboardType: TextInputType.number,
                      placeholder: const Text('150'),
                      validator: (v) => v.isEmpty ? 'Requerido' : null,
                      onSaved: (v) => m2 = double.tryParse(v!) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShadInputFormField(
                      label: const Text('Precio (USD)'),
                      keyboardType: TextInputType.number,
                      placeholder: const Text('120000'),
                      validator: (v) => v.isEmpty ? 'Requerido' : null,
                      onSaved: (v) => precio = double.tryParse(v!) ?? 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ShadInputFormField(
                      label: const Text('Habitaciones'),
                      keyboardType: TextInputType.number,
                      placeholder: const Text('3'),
                      validator: (v) => v.isEmpty ? 'Requerido' : null,
                      onSaved: (v) => habitaciones = int.tryParse(v!) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShadInputFormField(
                      label: const Text('Baños'),
                      keyboardType: TextInputType.number,
                      placeholder: const Text('2'),
                      validator: (v) => v.isEmpty ? 'Requerido' : null,
                      onSaved: (v) => banos = int.tryParse(v!) ?? 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Fotos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              ShadButton.secondary(
                onPressed: () {
                  // Stub para subir imagenes
                  ShadToaster.of(context).show(
                    const ShadToast(description: Text('Selección de fotos habilitada pronto.')),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload_file),
                    SizedBox(width: 8),
                    Text('Subir fotos de la propiedad'),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: ShadButton(
                  onPressed: isLoading ? null : _submitForm,
                  child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Crear Anuncio y Publicar'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Obtenemos el token activo de Storage y decodificamos el UUID del usuario logueado.
      final tokenStorage = ref.read(tokenStorageProvider);
      final token = await tokenStorage.getToken();
      String userId = "123e4567-e89b-12d3-a456-426614174000"; // fallback genérico en caso crítico
      if (token != null) {
        final extractedId = JwtUtils.extractUserId(token);
        if (extractedId != null) {
          userId = extractedId;
        }
      }
      
      // Armamos un Inmueble con valores mock necesarios y los recogidos del form
      final inmueble = Inmueble(
        tipoInmueble: 'CASA', // Mock
        areaTerreno: m2, 
        areaConstruida: m2,
        habitaciones: habitaciones,
        banos: banos,
        garajes: 1, // Mock
        antiguedadAnios: 5, // Mock
        ubicacion: Ubicacion(
           ciudad: "Santa Cruz", // Mock
           zonaBarrios: "Equipetrol", // Mock
           direccionExacta: "Direccion Genérica", // Mock
           latitud: "-17.7699",
           longitud: "-63.1979",
        ),
      );

      final pub = Publicacion(
        idUsuario: userId, // Extraído del JWT
        idInmueble: "", // Este se llenará en el controller al crearse el inmueble
        titulo: titulo,
        descripcionGeneral: descripcion,
        tipoTransaccion: "VENTA",
        precio: precio,
        moneda: "USD",
        estadoPublicacion: "ACTIVA",
        // Subimos unas fotos de prueba de Unsplash
        imagenesUrls: [
          "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=600&auto=format&fit=crop",
          "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=600&auto=format&fit=crop"
        ],
      );

      final success = await ref.read(createPublicationControllerProvider.notifier)
                               .createPublication(inmueble, pub);
                               
      if (success && mounted) {
        ShadToaster.of(context).show(
          const ShadToast(description: Text('¡Propiedad publicada con éxito!')),
        );
        context.pop(); // Vuelve al layout
      }
    }
  }
}
