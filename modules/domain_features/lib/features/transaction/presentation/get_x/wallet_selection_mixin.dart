import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:get/get.dart';

import '../../../../core/get_x/prj_get_controller.dart';
import '../../../../core/presentation/helper/last_entry_wallet.dart';

/// The liquid-wallet list and selection of a transaction form.
///
/// The selection is sticky: it stays through reloads and submits, and the
/// wallet last used ([LastEntryWallet]) is preselected in every form, also
/// after the app restarts. A form editing an old transaction keeps that
/// transaction's wallet and never changes the remembered one.
mixin WalletSelectionMixin on PrjGetController {
  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;
  final Rx<String?> selectedWalletId = Rx<String?>(null);

  Worker? _walletsWorker;
  Worker? _lastWalletWorker;

  /// Whether this form is editing an existing transaction.
  bool get hasEditing;

  /// Follows [source] (all wallets) from now on. Safe to call again: the
  /// previous listeners are replaced.
  void bindWallets(RxList<WalletEntity> source) {
    _disposeWalletWorkers();
    applyWallets(source);
    _walletsWorker = ever(source, applyWallets);
    _lastWalletWorker = ever(LastEntryWallet.changes, (String? id) {
      if (id != null && !hasEditing) setWalletIdIfListed(id);
    });
  }

  /// Takes the new wallet list. Investment positions aren't spendable or
  /// receivable like a normal wallet, so they are never offered.
  void applyWallets(List<WalletEntity> source) {
    wallets.assignAll(source.where((w) => w.type != WalletType.investment));
    ensureValidWalletSelection();
  }

  /// Keeps [selectedWalletId] pointing at a wallet that exists: the current
  /// one, else the remembered one, else the first. An empty list changes
  /// nothing: a list being reloaded is momentarily empty, and dropping the
  /// selection then would jump back to the first wallet.
  void ensureValidWalletSelection() {
    if (wallets.isEmpty) return;
    if (_hasWallet(selectedWalletId.value)) return;
    final remembered = LastEntryWallet.id;
    selectedWalletId.value = _hasWallet(remembered)
        ? remembered
        : wallets.first.id;
  }

  /// Selects [id] when it is one of [wallets].
  void setWalletIdIfListed(String id) {
    if (_hasWallet(id)) selectedWalletId.value = id;
  }

  /// A wallet chosen for this entry; also remembered unless editing.
  void setWalletId(String id) {
    if (!_hasWallet(id)) return;
    selectedWalletId.value = id;
    if (!hasEditing) LastEntryWallet.remember(id);
  }

  bool _hasWallet(String? id) => id != null && wallets.any((w) => w.id == id);

  void _disposeWalletWorkers() {
    _walletsWorker?.dispose();
    _lastWalletWorker?.dispose();
  }

  @override
  void onClose() {
    _disposeWalletWorkers();
    super.onClose();
  }
}
