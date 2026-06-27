import 'package:equatable/equatable.dart';

class CategoryGroupEntity extends Equatable {
  final String id;
  final String nameKey;

  const CategoryGroupEntity({required this.id, required this.nameKey});

  @override
  List<Object?> get props => [id, nameKey];
}
