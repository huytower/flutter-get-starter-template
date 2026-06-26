import 'package:equatable/equatable.dart';

/// Pure Domain Entity for Comment.
class CommentEntity extends Equatable {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  const CommentEntity({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  @override
  List<Object?> get props => [postId, id, name, email, body];
}
