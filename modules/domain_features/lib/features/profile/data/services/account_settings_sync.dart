import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constant/currency_constants.dart';
import '../datasources/account_settings_sync_datasource.dart';
import '../models/account_settings_snapshot.dart';

/// Keeps the account's own settings ([AccountSettingsSnapshot]) in step with
/// Firestore, so level, VIP, guideline progress, audit day, birth year and
/// book currency follow the account across devices and never leak from one
/// account (or a guest) to the next on a shared device.
///
/// Driven by `FinancialDataSyncService`: [adoptAccount] on sign-in / account
/// switch (before the financial pull, so the book currency is right when the
/// records arrive), [push] inside every `syncAll()`, [clearLocal] whenever the
/// financial cache is wiped.
@lazySingleton
class AccountSettingsSync {
  AccountSettingsSync(this._remote, this._session, this._refresh);

  final AccountSettingsSyncDataSource _remote;
  final SessionContract _session;
  final FinancialRefreshProvider _refresh;

  PrjAppStorage get _storage => PrjAppStorage.instance;

  AccountSettingsSnapshot get _local =>
      AccountSettingsSnapshot.fromStorage(_storage);

  AccountSettingsSnapshot? get _base =>
      AccountSettingsSnapshot.decode(_storage.accountSettingsSyncedJson);

  /// 1 while the signed-in account has settings the cloud has not seen; counts
  /// toward the sync badge and blocks sign-out like any pending record.
  int get pendingCount {
    if (_session.currentUser == null) return 0;
    return _local.sameAs(_base) ? 0 : 1;
  }

  /// Uploads local changes, merging any made on another device first.
  Future<void> push() async {
    if (pendingCount == 0) return;
    await _reconcile();
  }

  /// Makes the signed-in account's settings the device's settings.
  ///
  /// When the device held another account's or a guest's data, the cache wipe
  /// has already run [clearLocal]: with no synced base the cloud copy replaces
  /// the local fields (or, for an account with none, a fresh start is
  /// uploaded). For the returning owner both sides are merged.
  Future<void> adoptAccount() async {
    if (_session.currentUser == null) return;
    try {
      await _reconcile();
    } catch (e) {
      // Offline: the next syncAll() retries, since the copy stays pending.
      'Account settings not synced yet: $e'.Log('AccountSettingsSync');
    }
  }

  /// Resets the account fields to a brand-new account's state on this device.
  Future<void> clearLocal() async {
    final before = _local;
    AccountSettingsSnapshot.clearIn(_storage, now: DateTime.now());
    _storage.accountSettingsSyncedJson = null;
    await _storage.save();
    await _afterLocalChange(before);
  }

  Future<void> _reconcile() async {
    if (_session.currentUser == null) return;
    final before = _local;
    final remoteData = await _remote.fetch();
    final remote = remoteData == null
        ? null
        : AccountSettingsSnapshot.fromJson(remoteData);
    final merged = remote == null
        ? before
        : before.mergeWith(remote: remote, base: _base);

    if (!merged.sameAs(remote)) await _remote.push(merged.toJson());
    merged.applyTo(_storage);
    _storage.accountSettingsSyncedJson = merged.encode();
    await _storage.save();
    if (!merged.sameAs(before)) await _afterLocalChange(before);
  }

  Future<void> _afterLocalChange(AccountSettingsSnapshot before) async {
    if (_local.currencyCode != before.currencyCode) {
      CurrencyConstants.onCurrencyChanged.value++;
    }
    await _refresh.reloadAccountSettings();
  }
}
