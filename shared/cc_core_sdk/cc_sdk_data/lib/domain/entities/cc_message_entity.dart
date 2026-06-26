import 'package:equatable/equatable.dart';

/// Pure Domain Entity representing a notification message.
class CcMessageEntity extends Equatable {
  final String? messageId;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;

  const CcMessageEntity({
    this.messageId,
    this.title,
    this.body,
    this.data = const {},
  });

  @override
  List<Object?> get props => [messageId, title, body, data];
}
