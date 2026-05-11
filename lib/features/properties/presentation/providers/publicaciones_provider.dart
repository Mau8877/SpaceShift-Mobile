import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:space_shift/features/home/presentation/providers/property_filters_provider.dart';

import '../../data/publicacion_repository.dart';
import '../../domain/publicacion.dart';

part 'publicaciones_provider.g.dart';

@riverpod
Future<List<Publicacion>> publicaciones(Ref ref) {
  final filters = ref.watch(propertyFiltersControllerProvider);
  
  return ref.watch(publicacionRepositoryProvider).getPublicaciones(
    transactionType: filters.transactionType,
    location: filters.location.isEmpty ? null : filters.location,
    propertyType: filters.propertyType,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
  );
}
