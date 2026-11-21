import 'package:domain_features/features/transaction/presentation/get_x/tab_change_notifier.dart';
import 'package:domain_features/features/transaction/presentation/get_x/transaction_controller.dart';
import 'package:domain_features/features/transaction/presentation/get_x/transaction_form_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeForm implements TransactionFormController {
  final List<String> calls = [];

  @override
  void onTabActivated() => calls.add('activated');

  @override
  void onTabDeactivated() => calls.add('deactivated');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Map<TransactionTabKind, _FakeForm> forms;

  setUp(() {
    forms = {for (final t in TransactionTabKind.values) t: _FakeForm()};
  });

  void change(TransactionTabKind? from, TransactionTabKind? to) =>
      notifyTabChange(from: from, to: to, controllerOf: (t) => forms[t]);

  test('leaving one tab and opening another notifies each form once', () {
    change(TransactionTabKind.expense, TransactionTabKind.lend);

    expect(forms[TransactionTabKind.expense]!.calls, ['deactivated']);
    expect(forms[TransactionTabKind.lend]!.calls, ['activated']);
    expect(forms[TransactionTabKind.borrow]!.calls, isEmpty);
  });

  test('opening Cho mượn refreshes the lend form, not the borrow form', () {
    change(TransactionTabKind.borrow, TransactionTabKind.lend);

    expect(forms[TransactionTabKind.lend]!.calls, ['activated']);
    expect(forms[TransactionTabKind.borrow]!.calls, ['deactivated']);
  });

  test('staying on the same tab notifies nobody', () {
    change(TransactionTabKind.income, TransactionTabKind.income);

    expect(forms.values.expand((f) => f.calls), isEmpty);
  });

  test('a tab whose form is not built yet is skipped', () {
    notifyTabChange(
      from: TransactionTabKind.expense,
      to: TransactionTabKind.investment,
      controllerOf: (t) => t == TransactionTabKind.expense ? forms[t] : null,
    );

    expect(forms[TransactionTabKind.expense]!.calls, ['deactivated']);
  });
}
