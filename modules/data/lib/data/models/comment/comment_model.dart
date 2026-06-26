import 'package:domain_features/export_domain_features.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  final int? postId;
  final int? id;
  final String? name;
  final String? email;
  final String? body;

  CommentModel({this.postId, this.id, this.name, this.email, this.body});

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

  CommentEntity toEntity() => CommentEntity(
    postId: postId ?? 0,
    id: id ?? 0,
    name: name ?? '',
    email: email ?? '',
    body: body ?? '',
  );
}
