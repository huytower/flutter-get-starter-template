import 'dart:async';

import 'package:cc_sdk_data/data/models/pagination_request.dart';
import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:data_config/core/repository/cc_base_repository.dart';
import 'package:domain_features/export_domain_features.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../datasources/remote/comment_remote.dart';

@Singleton(as: CommentRepository)
class CommentRepositoryImpl with CcBaseRepository implements CommentRepository {
  @factoryMethod
  CommentRepositoryImpl({required CommentRemote remote}) : _remote = remote;

  final CommentRemote _remote;

  @override
  Future<Result<List<CommentEntity>, CcFailure>> getListComments() async {
    return safeRequest(() async {
      // 1. Call the remote source (The interceptor already peeled the JSON)
      final response = await _remote.getListComments();

      // 2. Map DTOs to Entities
      return response.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Result<List<CommentEntity>, CcFailure>> getComments(
    PaginationRequest request,
  ) async {
    return safeRequest(() async {
      // 1. Call the remote source with pagination parameters
      // The interceptor already peeled the JSON and preserved pagination metadata
      final response = await _remote.getComments(
        request.page,
        request.itemsPerPage,
      );

      // 2. Map DTOs to Entities
      return response.map((model) => model.toEntity()).toList();
    });
  }
}
