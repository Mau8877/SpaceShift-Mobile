import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/inmueble.dart';
import '../../domain/publicacion.dart';
import '../../domain/ubicacion.dart';
import '../../../contratos/domain/contrato_model.dart';
import '../providers/create_publication_controller.dart';
import '../providers/user_properties_provider.dart';
import '../providers/publicaciones_provider.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/publicacion_repository.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/network/jwt_utils.dart';

class CreatePublicationScreen extends ConsumerStatefulWidget {
  final Publicacion? publicacion;
  const CreatePublicationScreen({super.key, this.publicacion});

  @override
  ConsumerState<CreatePublicationScreen> createState() => _CreatePublicationScreenState();
}

class _CreatePublicationScreenState extends ConsumerState<CreatePublicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Form State
  late String titulo;
  late String descripcion;
  late double precio;
  late String tipoTransaccion;
  late String tipoInmueble;
  late double areaTerreno;
  late double areaConstruida;
  late int habitaciones;
  late int banos;
  late int garajes;
  late int antiguedadAnios;
  late String condiciones;
  late String multasSanciones;
  List<DispositivoInmueble> dispositivos = [];
  
  // Ubicación
  late String ciudad;
  late String zonaBarrios;
  late String direccionExacta;
  LatLng? selectedLocation;

  // Media
  List<XFile> images = [];
  List<String> existingImageUrls = [];

  @override
  void initState() {
    super.initState();
    final pub = widget.publicacion;
    final inm = pub?.inmueble;
    final ubi = inm?.ubicacion;

    titulo = pub?.titulo ?? '';
    descripcion = pub?.descripcionGeneral ?? '';
    precio = pub?.precio ?? 0;
    tipoTransaccion = pub?.tipoTransaccion.toLowerCase() ?? 'venta';
    tipoInmueble = inm?.tipoInmueble ?? 'DEPARTAMENTO';
    areaTerreno = inm?.areaTerreno ?? 0;
    areaConstruida = inm?.areaConstruida ?? 0;
    habitaciones = inm?.habitaciones ?? 0;
    banos = inm?.banos ?? 0;
    garajes = inm?.garajes ?? 0;
    antiguedadAnios = inm?.antiguedadAnios ?? 0;
    condiciones = inm?.condiciones ?? '';
    multasSanciones = inm?.multasSanciones ?? '';
    dispositivos = List<DispositivoInmueble>.from(inm?.dispositivos ?? []);
    
    ciudad = ubi?.ciudad ?? '';
    zonaBarrios = ubi?.zonaBarrios ?? '';
    direccionExacta = ubi?.direccionExacta ?? '';
    
    if (ubi != null && ubi.latitud.isNotEmpty) {
      selectedLocation = LatLng(double.parse(ubi.latitud), double.parse(ubi.longitud));
    } else {
      selectedLocation = const LatLng(-17.7833, -63.1821);
    }

    existingImageUrls = pub?.imagenesUrls ?? [];
  }

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        images.addAll(selectedImages);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(createPublicationControllerProvider);
    final isLoading = creationState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Inmueble'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información Básica'),
              ShadInputFormField(
                label: const Text('Título'),
                initialValue: titulo,
                placeholder: const Text('Ej. Penthouse en Equipetrol'),
                onSaved: (v) => titulo = v!,
                validator: (v) => v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              ShadInputFormField(
                label: const Text('Descripción'),
                initialValue: descripcion,
                minLines: 3,
                maxLines: 5,
                onSaved: (v) => descripcion = v!,
                validator: (v) => v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSelectField(
                      label: 'Transacción',
                      value: tipoTransaccion,
                      options: {'venta': 'Venta', 'alquiler': 'Alquiler'},
                      onChanged: (v) => setState(() => tipoTransaccion = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShadInputFormField(
                      label: const Text('Precio (USD)'),
                      initialValue: precio.toString(),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => precio = double.tryParse(v!) ?? 0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Detalles del Inmueble'),
              _buildSelectField(
                label: 'Tipo de Inmueble',
                value: tipoInmueble,
                options: {
                  'DEPARTAMENTO': 'Departamento',
                  'CASA': 'Casa',
                  'TERRENO': 'Terreno',
                  'OFICINA': 'Oficina'
                },
                onChanged: (v) => setState(() => tipoInmueble = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ShadInputFormField(
                      label: const Text('Área Terreno (m²)'),
                      initialValue: areaTerreno.toString(),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => areaTerreno = double.tryParse(v!) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShadInputFormField(
                      label: const Text('Área Construida (m²)'),
                      initialValue: areaConstruida.toString(),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => areaConstruida = double.tryParse(v!) ?? 0,
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
                      initialValue: habitaciones.toString(),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => habitaciones = int.tryParse(v!) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShadInputFormField(
                      label: const Text('Baños'),
                      initialValue: banos.toString(),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => banos = int.tryParse(v!) ?? 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ShadInputFormField(
                      label: const Text('Garajes'),
                      initialValue: garajes.toString(),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => garajes = int.tryParse(v!) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShadInputFormField(
                      label: const Text('Antigüedad (años)'),
                      initialValue: antiguedadAnios.toString(),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => antiguedadAnios = int.tryParse(v!) ?? 0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Condiciones y Dispositivos Inteligentes'),
              ShadInputFormField(
                label: const Text('Condiciones de Alquiler / Venta'),
                initialValue: condiciones,
                minLines: 2,
                maxLines: 4,
                placeholder: const Text('Ej. No se permiten mascotas, depósito de garantía...'),
                onSaved: (v) => condiciones = v ?? '',
              ),
              const SizedBox(height: 16),
              ShadInputFormField(
                label: const Text('Multas y Sanciones'),
                initialValue: multasSanciones,
                minLines: 2,
                maxLines: 4,
                placeholder: const Text('Ej. Multa de 50 USD por fumar en el inmueble...'),
                onSaved: (v) => multasSanciones = v ?? '',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dispositivos Inteligentes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ShadButton.outline(
                    onPressed: _showAddDeviceDialog,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 4),
                        Text('Agregar'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (dispositivos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No hay dispositivos registrados para este inmueble.',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dispositivos.length,
                  itemBuilder: (context, index) {
                    final dev = dispositivos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.devices, color: Colors.blue),
                        title: Text(dev.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (dev.descripcion.isNotEmpty) Text(dev.descripcion),
                            Text('Precio por día: \$${dev.precio} USD', style: const TextStyle(fontWeight: FontWeight.w500)),
                            if (dev.maxHorasSeguidas != null && dev.maxHorasSeguidas! > 0)
                              Text('Máx. horas continuas: ${dev.maxHorasSeguidas}h'),
                            if (dev.horarioLimiteUso != null && dev.horarioLimiteUso!.isNotEmpty)
                              Text('Restricción horario: ${dev.horarioLimiteUso} a ${dev.horarioLimiteFin ?? ''}'),
                            if (dev.sancionIncumplimiento != null && dev.sancionIncumplimiento!.isNotEmpty)
                              Text('Sanción: ${dev.sancionIncumplimiento}', style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              dispositivos.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),
              _buildSectionTitle('Ubicación'),
              ShadInputFormField(
                label: const Text('Ciudad'),
                initialValue: ciudad,
                onSaved: (v) => ciudad = v!,
              ),
              const SizedBox(height: 16),
              ShadInputFormField(
                label: const Text('Zona / Barrio'),
                initialValue: zonaBarrios,
                onSaved: (v) => zonaBarrios = v!,
              ),
              const SizedBox(height: 16),
              ShadInputFormField(
                label: const Text('Dirección Exacta'),
                initialValue: direccionExacta,
                onSaved: (v) => direccionExacta = v!,
              ),
              const SizedBox(height: 16),
              const Text('Ubicación en Mapa (Toca para marcar)', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: selectedLocation!,
                      initialZoom: 13,
                      onTap: (_, latLng) => setState(() => selectedLocation = latLng),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.spaceshift.app.mobile.v1',
                      ),
                      if (selectedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: selectedLocation!,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Fotos'),
              if (existingImageUrls.isNotEmpty || images.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: existingImageUrls.length + images.length,
                  itemBuilder: (context, index) {
                    final isExisting = index < existingImageUrls.length;
                    final imageUrl = isExisting ? existingImageUrls[index] : null;
                    final localFile = isExisting ? null : images[index - existingImageUrls.length];

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: isExisting 
                                ? Image.network(imageUrl!, fit: BoxFit.cover)
                                : Image.file(File(localFile!.path), fit: BoxFit.cover),
                          ),
                        ),
                        if (index == 0)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('PORTADA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isExisting) {
                                  existingImageUrls.removeAt(index);
                                } else {
                                  images.removeAt(index - existingImageUrls.length);
                                }
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 16),
              ShadButton.outline(
                onPressed: _pickImages,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo),
                    SizedBox(width: 8),
                    Text('Añadir fotos'),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ShadButton(
                  onPressed: isLoading ? null : _submitForm,
                  child: isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(widget.publicacion == null ? 'Publicar Propiedad' : 'Guardar Cambios'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSelectField({
    required String label,
    required String value,
    required Map<String, String> options,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ShadSelect<String>(
          initialValue: options.containsKey(value) ? value : null,
          placeholder: const Text('Seleccionar...'),
          onChanged: onChanged,
          options: options.entries.map((e) => ShadOption(value: e.key, child: Text(e.value))).toList(),
          selectedOptionBuilder: (context, val) => Text(options[val] ?? 'Seleccionar'),
        ),
      ],
    );
  }

  void _showAddDeviceDialog() {
    final deviceFormKey = GlobalKey<FormState>();
    String devNombre = '';
    String devDescripcion = '';
    double devPrecio = 0.0;
    int? devMaxHoras;
    bool hasTimeRestriction = false;
    String devHorarioLimiteUso = '22:00';
    String devHorarioLimiteFin = '06:00';
    String? devSancion;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Agregar Dispositivo Inteligente'),
              content: SingleChildScrollView(
                child: Form(
                  key: deviceFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Nombre del Dispositivo*'),
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        onSaved: (v) => devNombre = v!,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Descripción'),
                        onSaved: (v) => devDescripcion = v ?? '',
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Precio por Día (USD)*'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (double.tryParse(v) == null) return 'Debe ser un número';
                          return null;
                        },
                        onSaved: (v) => devPrecio = double.parse(v!),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Máx. horas continuas (opcional)',
                          hintText: 'Ej. 2',
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (v) => devMaxHoras = v != null && v.isNotEmpty ? int.tryParse(v) : null,
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: const Text('Restringir el uso en un horario específico', style: TextStyle(fontSize: 14)),
                        value: hasTimeRestriction,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setDialogState(() {
                            hasTimeRestriction = val ?? false;
                          });
                        },
                      ),
                      if (hasTimeRestriction) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: devHorarioLimiteUso,
                                decoration: const InputDecoration(
                                  labelText: 'Desde',
                                  hintText: 'Ej. 22:00',
                                ),
                                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                onSaved: (v) => devHorarioLimiteUso = v!,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                initialValue: devHorarioLimiteFin,
                                decoration: const InputDecoration(
                                  labelText: 'Hasta',
                                  hintText: 'Ej. 06:00',
                                ),
                                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                onSaved: (v) => devHorarioLimiteFin = v!,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Sanción o Multa por Incumplimiento (opcional)',
                          hintText: 'Ej. Multa de 10 USD',
                        ),
                        onSaved: (v) => devSancion = v != null && v.isNotEmpty ? v : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (deviceFormKey.currentState!.validate()) {
                      deviceFormKey.currentState!.save();
                      final newDevice = DispositivoInmueble(
                        id: UniqueKey().toString(),
                        nombre: devNombre,
                        precio: devPrecio,
                        tipoPrecio: 'POR_DIA',
                        configuracionTiempo: 'LIBRE',
                        horarioInicio: '00:00',
                        horarioFin: '23:59',
                        descripcion: devDescripcion,
                        maxHorasSeguidas: devMaxHoras,
                        horarioLimiteUso: hasTimeRestriction ? devHorarioLimiteUso : null,
                        horarioLimiteFin: hasTimeRestriction ? devHorarioLimiteFin : null,
                        sancionIncumplimiento: devSancion,
                      );
                      setState(() {
                        dispositivos.add(newDevice);
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (images.isEmpty && existingImageUrls.isEmpty) {
        ShadToaster.of(context).show(const ShadToast.destructive(description: Text('Debes añadir al menos una foto.')));
        return;
      }
      
      _formKey.currentState!.save();
      
      final tokenStorage = ref.read(tokenStorageProvider);
      final token = await tokenStorage.getToken();
      String userId = "";
      if (token != null) {
        userId = JwtUtils.extractUserId(token) ?? "";
      }

      try {
        // 1. Subir imágenes nuevas si las hay
        List<String> newUrls = [];
        if (images.isNotEmpty) {
          final repository = ref.read(publicacionRepositoryProvider);
          final List<File> files = images.map((x) => File(x.path)).toList();
          newUrls = await repository.uploadImages(files);
        }

        final allUrls = [...existingImageUrls, ...newUrls];

        // 2. Preparar objetos
        final inmueble = Inmueble(
          id: widget.publicacion?.idInmueble,
          tipoInmueble: tipoInmueble,
          areaTerreno: areaTerreno,
          areaConstruida: areaConstruida,
          habitaciones: habitaciones,
          banos: banos,
          garajes: garajes,
          antiguedadAnios: antiguedadAnios,
          condiciones: condiciones,
          multasSanciones: multasSanciones,
          dispositivos: dispositivos,
          ubicacion: Ubicacion(
            id: widget.publicacion?.inmueble?.ubicacion.id,
            ciudad: ciudad,
            zonaBarrios: zonaBarrios,
            direccionExacta: direccionExacta,
            latitud: selectedLocation?.latitude.toString() ?? '',
            longitud: selectedLocation?.longitude.toString() ?? '',
          ),
        );

        final pub = Publicacion(
          id: widget.publicacion?.id,
          idUsuario: userId,
          idInmueble: widget.publicacion?.idInmueble ?? "",
          titulo: titulo,
          descripcionGeneral: descripcion,
          tipoTransaccion: tipoTransaccion.toUpperCase(),
          precio: precio,
          moneda: "USD",
          estadoPublicacion: "ACTIVA",
          imagenesUrls: allUrls,
          inmueble: inmueble, // <--- Faltaba vincular el inmueble aquí
        );

        bool success = false;
        if (widget.publicacion == null) {
          success = await ref.read(createPublicationControllerProvider.notifier)
                                 .createPublication(inmueble, pub);
        } else {
           // Lógica de update
           print('--- DATOS ENVIADOS DESDE MÓVIL ---');
           print(pub.toJson());
           print('----------------------------------');
           
           await (ref.read(publicacionRepositoryProvider) as dynamic).updatePublication(pub.id!, pub);
           ref.invalidate(userPropertiesProvider);
           ref.invalidate(publicacionesProvider); // Refrescar el Explorar
           success = true;
        }
                                 
        if (success && mounted) {
          // Si fue creación, también refrescamos el Explorar
          if (widget.publicacion == null) {
            ref.invalidate(publicacionesProvider);
          }
          ShadToaster.of(context).show(ShadToast(description: Text(widget.publicacion == null ? '¡Publicación exitosa!' : '¡Cambios guardados!')));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ShadToaster.of(context).show(ShadToast.destructive(description: Text('Error: $e')));
        }
      }
    }
  }
}
