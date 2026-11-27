import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/di/di.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/get_x/followed_workers_mixin.dart';
import 'package:domain_features/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:domain_features/features/liability/presentation/get_x/borrow_form_controller.dart';
import 'package:domain_features/features/liability/presentation/get_x/lend_form_controller.dart';
import 'package:domain_features/features/profile/domain/usecases/get_profile_settings_usecase.dart';
import 'package:domain_features/features/report/presentation/get_x/quick_edit_transaction_sheet_controller.dart';
import 'package:domain_features/features/transaction/domain/usecases/create_investment_transaction_usecase.dart';
import 'package:domain_features/features/transaction/presentation/get_x/investment_form_controller.dart';
import 'package:domain_features/features/transaction/presentation/get_x/quick_entry_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Categories implements GetCategoriesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Settings implements GetProfileSettingsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Create implements CreateInvestmentTransactionUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Guideline implements GuidelineProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _QuickEntry implements QuickEntryHandler {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

InvestmentFormController _investmentForm() => InvestmentFormController(
  _Categories(),
  _Settings(),
  _Create(),
  _Guideline(),
  _QuickEntry(),
);

// The sheet's lifecycle only: these forms skip their loading and closing.
final _opened = <GetxController>[];
final _closed = <GetxController>[];

class _Investment extends InvestmentFormController {
  _Investment()
    : super(_Categories(), _Settings(), _Create(), _Guideline(), _QuickEntry());

  @override
  // ignore: must_call_super
  void onInit() => _opened.add(this);

  @override
  // ignore: must_call_super
  void onClose() => _closed.add(this);
}

class _Borrow extends BorrowFormController {
  _Borrow() : super(_QuickEntry());

  @override
  // ignore: must_call_super
  void onInit() => _opened.add(this);

  @override
  // ignore: must_call_super
  void onClose() => _closed.add(this);
}

class _Lend extends LendFormController {
  _Lend() : super(_QuickEntry());

  @override
  // ignore: must_call_super
  void onInit() => _opened.add(this);

  @override
  // ignore: must_call_super
  void onClose() => _closed.add(this);
}

class _Follower extends GetxController with FollowedWorkersMixin {
  _Follower(this.source);

  final RxInt source;
  final seen = <int>[];

  @override
  void onInit() {
    super.onInit();
    follow(source, seen.add);
  }
}

TransactionEntity _entry(String type) => TransactionEntity(
  id: 'e1',
  type: type,
  amount: 1,
  category: '',
  date: DateTime(2026),
  walletId: 'w',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _opened.clear();
    _closed.clear();
  });

  tearDown(() async {
    Get.reset();
    await getIt.reset();
  });

  // The quick edit sheet resolves its forms from getIt itself.
  void register() {
    getIt
      ..registerFactory<InvestmentFormController>(_Investment.new)
      ..registerFactory<BorrowFormController>(_Borrow.new)
      ..registerFactory<LendFormController>(_Lend.new);
  }

  for (final type in [
    TransactionType.investmentReturn,
    TransactionType.debtBorrow,
    TransactionType.debtLend,
  ]) {
    test('the $type form closes with its sheet and is not reused', () async {
      register();

      for (var opening = 1; opening <= 2; opening++) {
        final sheet = QuickEditTransactionSheetController()
          ..prepareForm(_entry(type), () {});
        sheet.onClose();
        await pumpEventQueue();

        expect(_opened, hasLength(opening), reason: 'a new form each time');
        expect(_closed, _opened);
      }
    });
  }

  test('a followed notifier is dropped when the controller closes', () async {
    final source = 0.obs;
    final follower = Get.put<_Follower>(_Follower(source));

    source.value = 1;
    await Get.delete<_Follower>();
    source.value = 2;
    await pumpEventQueue();

    expect(follower.seen, [1]);
  });

  // These forms were never closed before, so their closing had never run.
  test('the real forms close without errors', () {
    expect(_investmentForm().onClose, returnsNormally);
    expect(BorrowFormController(_QuickEntry()).onClose, returnsNormally);
    expect(LendFormController(_QuickEntry()).onClose, returnsNormally);
  });
}
