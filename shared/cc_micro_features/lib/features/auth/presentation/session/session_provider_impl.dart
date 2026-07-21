import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/usecases/auth_state_changes_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

/// Implementation of the SessionBridge.
///
/// This class lives in the Auth feature because it owns the Auth logic,
/// but it fulfills a contract that anyone can use via the Bridge.
@LazySingleton(as: SessionContract)
class SessionProviderImpl implements SessionContract {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthStateChangesUseCase _authStateChangesUseCase;
  final LogoutUseCase _logoutUseCase;

  // Internal state using the stable Bridge Entity
  final BehaviorSubject<CcUserEntity?> _userSubject =
      BehaviorSubject<CcUserEntity?>.seeded(null);

  SessionProviderImpl(
    this._getCurrentUserUseCase,
    this._authStateChangesUseCase,
    this._logoutUseCase,
  ) {
    _init();
  }

  Future<void> _init() async {
    // Initial load
    final result = await _getCurrentUserUseCase();
    result.when((userEntity) {
      if (userEntity != null) {
        'Initial session user: ${userEntity.id}'.Log('SessionProvider');
        _userSubject.add(_mapToBridge(userEntity));
      }
    }, (failure) => _userSubject.add(null));

    // Listen to changes
    _authStateChangesUseCase().listen((userEntity) {
      'Auth state changed: ${userEntity?.id}'.Log('SessionProvider');
      _userSubject.add(userEntity != null ? _mapToBridge(userEntity) : null);
    });
  }

  @override
  bool get isAuthenticated => _userSubject.value != null;

  @override
  CcUserEntity? get currentUser => _userSubject.value;

  @override
  Stream<CcUserEntity?> get userStream => _userSubject.stream;

  @override
  Future<void> clearSession() async {
    await _logoutUseCase();
    _userSubject.add(null);
  }

  /// THE MAPPING SHIELD:
  /// This protects features from changes in data.DomainUserEntity (Data Module).
  /// Since DomainUserEntity extends CcUserEntity, we can return it directly.
  CcUserEntity _mapToBridge(CcUserEntity entity) {
    return entity; // DomainUserEntity extends CcUserEntity
  }
}
