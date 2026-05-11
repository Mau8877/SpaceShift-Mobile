import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:space_shift/features/home/domain/property_filters.dart';

part 'property_filters_provider.g.dart';

@riverpod
class PropertyFiltersController extends _$PropertyFiltersController {
  @override
  PropertyFilters build() {
    return PropertyFilters();
  }

  void updateLocation(String location) {
    state = state.copyWith(location: location);
  }

  void updateTransactionType(String? type) {
    if (type == state.transactionType) {
      state = state.copyWith(clearTransactionType: true);
    } else {
      state = state.copyWith(transactionType: type);
    }
  }

  void updatePropertyType(String? type) {
    if (type == null) {
      state = state.copyWith(clearPropertyType: true);
    } else {
      state = state.copyWith(propertyType: type);
    }
  }

  void updatePriceRange(double? min, double? max) {
    if (min == null && max == null) {
      state = state.copyWith(clearPriceRange: true);
    } else {
      state = state.copyWith(minPrice: min, maxPrice: max);
    }
  }

  void clearFilters() {
    state = PropertyFilters();
  }
}
