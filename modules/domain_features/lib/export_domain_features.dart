library domain_features;

// Core
export 'core/di/di.dart';
export 'core/getx/cc_get_controller.dart';
export 'core/getx/cc_get_view.dart';
export 'core/navigation/domain_router.gr.dart';
// Budget Allocation (composite: Wallet + Budget Limit)
export 'features/budget_allocation/export_budget_allocation.dart';
// Budget Limit
export 'features/budget_limit/export_budget_limit.dart';
// Category
export 'features/category/export_category.dart';
// Comment
export 'features/comment/domain/entities/comment_entity.dart';
export 'features/comment/domain/repositories/comment_repository.dart';
export 'features/comment/presentation/get_x/comment_controller.dart';
export 'features/comment/presentation/ui/comment_detail_page.dart';
export 'features/comment/presentation/ui/comment_page.dart';
// Examples
export 'features/examples/bloc_simple_page/cubit/simple/simple_cubit_page.dart';
export 'features/examples/bloc_simple_page/origin/advance/advance_bloc_page.dart';
// Profile
export 'features/profile/export_profile.dart';
// Reconciliation
export 'features/reconciliation/export_reconciliation.dart';
// Report
export 'features/report/export_report.dart';
// Transaction
export 'features/transaction/domain/entities/transaction_entity.dart';
export 'features/transaction/domain/repositories/transaction_repository.dart';
export 'features/transaction/export_transaction.dart';
// Wallet
export 'features/wallet/domain/entities/wallet_entity.dart';
export 'features/wallet/domain/repositories/wallet_repository.dart';
export 'features/wallet/export_wallet.dart';
