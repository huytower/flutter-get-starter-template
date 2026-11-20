import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_micro_features/features/auth/domain/repositories/auth_repository.dart';
import 'package:cc_micro_features/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../firestore/financial_data_sync_service.dart';

/// Account actions reachable from the profile: who is signed in, display
/// name, sign-out, account deletion and the route to the login screen.
@injectable
class ProfileAccountActions {
  ProfileAccountActions(
    this._session,
    this._authRepository,
    this._deleteAccount,
    this._syncService,
    this._authCoordinator,
  );

  final SessionContract _session;
  final AuthRepository _authRepository;
  final DeleteAccountUseCase _deleteAccount;
  final FinancialDataSyncService _syncService;
  final AuthCoordinator _authCoordinator;

  FinancialDataSyncService get syncService => _syncService;

  Stream<CcUserEntity?> get userStream => _session.userStream;

  Future<Result<CcUserEntity, CcFailure>> updateDisplayName(String name) =>
      _authRepository.updateDisplayName(name);

  /// Guards sign-out so the user can never leave behind unsynced financial
  /// records. Returns the reason it was refused, or null on success.
  Future<LogoutResult?> logout() async {
    final result = await _syncService.logoutSafely();
    return result == LogoutResult.success ? null : result;
  }

  bool get canLogout => _syncService.canLogout();

  /// Null when logout is allowed, otherwise why it is blocked.
  LogoutBlock? get logoutBlock => _syncService.logoutBlock;

  /// Deletes the account, then wipes the local financial data and session.
  Future<Result<Unit, CcFailure>> deleteAccount() async {
    final result = await _deleteAccount.call();
    if (result.isSuccess()) {
      await _syncService.handleAccountDeleted();
      await _session.clearSession();
    }
    return result;
  }

  void openLogin(BuildContext context) =>
      _authCoordinator.navigateToLogin(context);
}
