import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/transaction_template_entity.dart';
import '../repositories/transaction_template_repository.dart';

class CreateTransactionTemplateParams {
  final String name;
  final int amount;
  final String categoryId;
  final String categoryLabel;
  final int? categoryIconCode;
  final String? categoryIconFamily;
  final String walletId;

  const CreateTransactionTemplateParams({
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.categoryLabel,
    this.categoryIconCode,
    this.categoryIconFamily,
    required this.walletId,
  });
}

@lazySingleton
class CreateTransactionTemplateUseCase {
  CreateTransactionTemplateUseCase(this._repository);

  final TransactionTemplateRepository _repository;

  Future<Result<TransactionTemplateEntity, CcFailure>> call(
    CreateTransactionTemplateParams params,
  ) async {
    if (params.name.trim().isEmpty) {
      return const Error(
        ValidationFailure(
          CcLocaleKeys.transaction_template_name_required,
        ),
      );
    }
    if (params.amount <= 0) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_amount_required),
      );
    }
    if (params.categoryId.isEmpty) {
      return const Error(
        ValidationFailure(
          CcLocaleKeys.transaction_validation_category_required,
        ),
      );
    }
    if (params.walletId.isEmpty) {
      return const Error(
        ValidationFailure(CcLocaleKeys.transaction_validation_wallet_required),
      );
    }

    final template = TransactionTemplateEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: params.name.trim(),
      amount: params.amount,
      categoryId: params.categoryId,
      categoryLabel: params.categoryLabel,
      categoryIconCode: params.categoryIconCode,
      categoryIconFamily: params.categoryIconFamily,
      walletId: params.walletId,
    );

    final result = await _repository.createTemplate(template);
    if (result.isError()) {
      return Error(result.tryGetError()!);
    }
    return Success(template);
  }
}
