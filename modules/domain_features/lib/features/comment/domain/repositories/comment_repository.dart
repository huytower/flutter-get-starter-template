import 'dart:async';

import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/comment_entity.dart';

abstract class CommentRepository {
  /// Get all comments without pagination (legacy support).
  Future<Result<List<CommentEntity>, CcFailure>> getListComments();

  /// Get comments with pagination support.
  ///
  /// Parameters:
  /// - [request]: Pagination request with page and items per page
  ///
  /// Returns a result containing the list of comments for the requested page.
  Future<Result<List<CommentEntity>, CcFailure>> getComments(
    CcPaginationRequest request,
  );
}
