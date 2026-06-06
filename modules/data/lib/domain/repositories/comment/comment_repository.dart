import 'dart:async';

import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:cc_sdk/domain/models/pagination_request.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../entities/comment/comment_entity.dart';

abstract class CommentRepository {
  /// Get comments with pagination support.
  ///
  /// Parameters:
  /// - [request]: Pagination request with page and items per page
  ///
  /// Returns a result containing the list of comments for the requested page.
  Future<Result<List<CommentEntity>, Failure>> getComments(
    PaginationRequest request,
  );
}
