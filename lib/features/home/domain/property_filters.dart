class PropertyFilters {
  final String? transactionType;
  final String location;
  final String? propertyType;
  final double? minPrice;
  final double? maxPrice;

  PropertyFilters({
    this.transactionType,
    this.location = '',
    this.propertyType,
    this.minPrice,
    this.maxPrice,
  });

  PropertyFilters copyWith({
    String? transactionType,
    String? location,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    bool clearTransactionType = false,
    bool clearPropertyType = false,
    bool clearPriceRange = false,
  }) {
    return PropertyFilters(
      transactionType: clearTransactionType ? null : (transactionType ?? this.transactionType),
      location: location ?? this.location,
      propertyType: clearPropertyType ? null : (propertyType ?? this.propertyType),
      minPrice: clearPriceRange ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPriceRange ? null : (maxPrice ?? this.maxPrice),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyFilters &&
          runtimeType == other.runtimeType &&
          transactionType == other.transactionType &&
          location == other.location &&
          propertyType == other.propertyType &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice;

  @override
  int get hashCode =>
      transactionType.hashCode ^
      location.hashCode ^
      propertyType.hashCode ^
      minPrice.hashCode ^
      maxPrice.hashCode;
}
