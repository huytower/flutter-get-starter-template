import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/transaction_template_entity.dart';
import '../../domain/usecases/create_transaction_template_usecase.dart';
import '../../domain/usecases/delete_transaction_template_usecase.dart';
import '../../domain/usecases/get_transaction_templates_usecase.dart';

/// Cross-cutting singleton (not tied to one page) backing the "Quick
/// templates" chip strip on the Expense form. Kept alive across form
/// rebuilds like [UserLevelController] so re-entering the Transaction tab
/// doesn't lose the loaded list.
@lazySingleton
class TransactionTemplateController extends GetxController {
  TransactionTemplateController(
    this._getTemplates,
    this._createTemplate,
    this._deleteTemplate,
  );

  final GetTransactionTemplatesUseCase _getTemplates;
  final CreateTransactionTemplateUseCase _createTemplate;
  final DeleteTransactionTemplateUseCase _deleteTemplate;

  final RxList<TransactionTemplateEntity> templates =
      <TransactionTemplateEntity>[].obs;

  Future<void> loadTemplates() async {
    final result = await _getTemplates.call();
    result.when((success) => templates.assignAll(success), (_) {});
  }

  /// Returns null on success, or an error message to surface to the user.
  Future<String?> createTemplate(CreateTransactionTemplateParams params) async {
    final result = await _createTemplate.call(params);
    return result.when((_) {
      loadTemplates();
      return null;
    }, (error) => error.message);
  }

  Future<void> deleteTemplate(String id) async {
    final result = await _deleteTemplate.call(id);
    result.when((_) => loadTemplates(), (_) {});
  }
}
