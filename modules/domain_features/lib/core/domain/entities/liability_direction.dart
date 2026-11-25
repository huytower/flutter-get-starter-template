/// Direction values stored in [LiabilityEntity.direction].
abstract class LiabilityDirection {
  /// Đi vay — money flows into the user's wallet, owed back later.
  static const String borrow = 'borrow';

  /// Cho vay — money flows out of the user's wallet, reclaimable later.
  static const String lend = 'lend';
}

