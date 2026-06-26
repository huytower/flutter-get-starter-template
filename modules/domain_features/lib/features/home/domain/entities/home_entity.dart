/// Dashboard Entity - Domain Layer
///
/// This class represents the common business object for the dashboard feature.
/// It follows the Single Responsibility Principle by only containing
/// dashboard-related business logic and data.
class HomeEntity {
  final String title;
  final String description;
  final int itemCount;
  final DateTime lastUpdated;

  const HomeEntity({
    required this.title,
    required this.description,
    required this.itemCount,
    required this.lastUpdated,
  });

  /// Creates a copy of this entity with updated values
  /// Following the Immutability principle
  HomeEntity copyWith({
    String? title,
    String? description,
    int? itemCount,
    DateTime? lastUpdated,
  }) {
    return HomeEntity(
      title: title ?? this.title,
      description: description ?? this.description,
      itemCount: itemCount ?? this.itemCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeEntity &&
        other.title == title &&
        other.description == description &&
        other.itemCount == itemCount &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        description.hashCode ^
        itemCount.hashCode ^
        lastUpdated.hashCode;
  }

  @override
  String toString() {
    return 'DashboardEntity(title: $title, description: $description, itemCount: $itemCount, lastUpdated: $lastUpdated)';
  }
}
