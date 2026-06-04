import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../models/comment/comment_model.dart';

part 'comment_remote.g.dart';

@singleton
@RestApi()
abstract class CommentRemote {
  @factoryMethod
  factory CommentRemote(@Named('baseDio') Dio dio) = _CommentRemote;

  /// Get all comments with pagination support.
  /// The CcResponseInterceptor handles peeling the envelope.
  ///
  /// Parameters:
  /// - [page]: Page number (1-based, default: 1)
  /// - [perPage]: Number of items per page (default: 20)
  ///
  /// Returns a list of comments for the specified page.
  @GET('/comments')
  Future<List<CommentModel>> getComments(
    @Query('page') int page,
    @Query('per_page') int perPage,
  );

  /// Get all comments without pagination (legacy support).
  /// The CcResponseInterceptor handles peeling the envelope.
  @GET('/comments')
  Future<List<CommentModel>> getListComments();
}
