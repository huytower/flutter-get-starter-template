import 'package:equatable/equatable.dart';

import 'wallet_entity.dart';

/// Pairs a wallet with its computed book balance (used by reconciliation).
class WalletBalanceEntity extends Equatable {
  final WalletEntity wallet;
  final int bookBalance;

  const WalletBalanceEntity({required this.wallet, required this.bookBalance});

  WalletBalanceEntity copyWith({WalletEntity? wallet, int? bookBalance}) {
    return WalletBalanceEntity(
      wallet: wallet ?? this.wallet,
      bookBalance: bookBalance ?? this.bookBalance,
    );
  }

  @override
  List<Object?> get props => [wallet.id, bookBalance];
}
