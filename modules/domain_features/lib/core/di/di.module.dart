// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:cc_bridge/export_cc_bridge.dart' as _i727;
import 'package:dio/dio.dart' as _i361;
import 'package:domain_features/export_domain_features.dart' as _i857;
import 'package:domain_features/features/budget/data/datasources/local/budget_local_datasource.dart'
    as _i595;
import 'package:domain_features/features/budget/data/repositories/budget_repository_impl.dart'
    as _i1007;
import 'package:domain_features/features/budget/domain/repositories/budget_repository.dart'
    as _i192;
import 'package:domain_features/features/budget/domain/usecases/create_budget_usecase.dart'
    as _i685;
import 'package:domain_features/features/budget/domain/usecases/delete_budget_usecase.dart'
    as _i46;
import 'package:domain_features/features/budget/domain/usecases/get_budget_stats_usecase.dart'
    as _i1058;
import 'package:domain_features/features/budget/domain/usecases/get_budgets_usecase.dart'
    as _i807;
import 'package:domain_features/features/budget/domain/usecases/reset_budget_usecase.dart'
    as _i80;
import 'package:domain_features/features/budget/domain/usecases/update_budget_limit_usecase.dart'
    as _i205;
import 'package:domain_features/features/budget/presentation/get_x/budget_controller.dart'
    as _i402;
import 'package:domain_features/features/category/data/datasources/local/category_local_datasource.dart'
    as _i547;
import 'package:domain_features/features/category/data/repositories/category_repository_impl.dart'
    as _i658;
import 'package:domain_features/features/category/domain/repositories/category_repository.dart'
    as _i1059;
import 'package:domain_features/features/category/domain/usecases/create_category_usecase.dart'
    as _i370;
import 'package:domain_features/features/category/domain/usecases/delete_category_usecase.dart'
    as _i1057;
import 'package:domain_features/features/category/domain/usecases/get_categories_usecase.dart'
    as _i224;
import 'package:domain_features/features/category/domain/usecases/get_category_groups_usecase.dart'
    as _i397;
import 'package:domain_features/features/category/domain/usecases/toggle_category_enabled_usecase.dart'
    as _i110;
import 'package:domain_features/features/comment/data/datasources/remote/comment_remote.dart'
    as _i130;
import 'package:domain_features/features/comment/data/repositories/comment_repository_impl.dart'
    as _i536;
import 'package:domain_features/features/comment/domain/repositories/comment_repository.dart'
    as _i670;
import 'package:domain_features/features/comment/presentation/get_x/comment_controller.dart'
    as _i730;
import 'package:domain_features/features/crashlog/data/datasource/remote/crash_log_remote.dart'
    as _i580;
import 'package:domain_features/features/crashlog/data/repositories/crash_log_repository_impl.dart'
    as _i689;
import 'package:domain_features/features/crashlog/domain/repositories/crash_log_repository.dart'
    as _i473;
import 'package:domain_features/features/crashlog/domain/usecases/upload_pending_crash_logs_usecase.dart'
    as _i892;
import 'package:domain_features/features/examples/bloc_simple_page/cubit/simple/simple_cubit.dart'
    as _i691;
import 'package:domain_features/features/examples/bloc_simple_page/cubit/simple/simple_cubit_interface.dart'
    as _i402;
import 'package:domain_features/features/examples/bloc_simple_page/origin/advance/advance_bloc.dart'
    as _i1004;
import 'package:domain_features/features/home/data/datasources/remote/home_remote.dart'
    as _i55;
import 'package:domain_features/features/home/data/repositories/home_repository_impl.dart'
    as _i179;
import 'package:domain_features/features/home/domain/repositories/home_repository.dart'
    as _i269;
import 'package:domain_features/features/home/presentation/get_x/home_controller.dart'
    as _i971;
import 'package:domain_features/features/reconciliation/data/datasources/local/reconciliation_local_datasource.dart'
    as _i896;
import 'package:domain_features/features/reconciliation/data/repositories/reconciliation_repository_impl.dart'
    as _i513;
import 'package:domain_features/features/reconciliation/domain/repositories/reconciliation_repository.dart'
    as _i944;
import 'package:domain_features/features/reconciliation/domain/usecases/get_reconciliation_history_usecase.dart'
    as _i446;
import 'package:domain_features/features/reconciliation/domain/usecases/perform_reconciliation_usecase.dart'
    as _i804;
import 'package:domain_features/features/reconciliation/domain/usecases/undo_reconciliation_usecase.dart'
    as _i195;
import 'package:domain_features/features/reconciliation/presentation/get_x/reconciliation_controller.dart'
    as _i1051;
import 'package:domain_features/features/report/domain/usecases/get_category_spending_usecase.dart'
    as _i169;
import 'package:domain_features/features/report/domain/usecases/get_monthly_summary_usecase.dart'
    as _i850;
import 'package:domain_features/features/report/presentation/get_x/report_controller.dart'
    as _i353;
import 'package:domain_features/features/transaction/data/datasources/local/transaction_local_datasource.dart'
    as _i648;
import 'package:domain_features/features/transaction/data/repositories/transaction_repository_impl.dart'
    as _i1032;
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart'
    as _i1027;
import 'package:domain_features/features/transaction/domain/usecases/create_transaction_usecase.dart'
    as _i28;
import 'package:domain_features/features/transaction/domain/usecases/create_transfer_usecase.dart'
    as _i627;
import 'package:domain_features/features/transaction/presentation/get_x/transaction_controller.dart'
    as _i700;
import 'package:domain_features/features/wallet/data/datasources/local/wallet_local_datasource.dart'
    as _i1058;
import 'package:domain_features/features/wallet/data/repositories/wallet_repository_impl.dart'
    as _i589;
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart'
    as _i572;
import 'package:domain_features/features/wallet/domain/usecases/get_wallet_balances_usecase.dart'
    as _i167;
import 'package:domain_features/features/wallet/domain/usecases/get_wallet_book_balance_usecase.dart'
    as _i105;
import 'package:domain_features/features/wallet/presentation/get_x/wallet_controller.dart'
    as _i229;
import 'package:injectable/injectable.dart' as _i526;

class DomainFeaturesPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.lazySingleton<_i595.BudgetLocalDataSource>(
        () => _i595.BudgetLocalDataSource());
    gh.lazySingleton<_i547.CategoryLocalDataSource>(
        () => _i547.CategoryLocalDataSource());
    gh.lazySingleton<_i1004.AdvanceBloc>(
      () => _i1004.AdvanceBloc(),
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i896.ReconciliationLocalDataSource>(
        () => _i896.ReconciliationLocalDataSource());
    gh.lazySingleton<_i648.TransactionLocalDataSource>(
        () => _i648.TransactionLocalDataSource());
    gh.lazySingleton<_i1058.WalletLocalDataSource>(
        () => _i1058.WalletLocalDataSource());
    gh.lazySingleton<_i857.TransactionRepository>(() =>
        _i1032.TransactionRepositoryImpl(
            local: gh<_i648.TransactionLocalDataSource>()));
    gh.lazySingleton<_i130.CommentRemote>(
        () => _i130.CommentRemote(gh<_i361.Dio>(instanceName: 'baseDio')));
    gh.lazySingleton<_i55.HomeRemote>(
        () => _i55.HomeRemote(gh<_i361.Dio>(instanceName: 'baseDio')));
    gh.lazySingleton<_i857.HomeRepository>(
        () => _i179.HomeRepositoryImpl(remote: gh<_i55.HomeRemote>()));
    gh.lazySingleton<_i944.ReconciliationRepository>(() =>
        _i513.ReconciliationRepositoryImpl(
            local: gh<_i896.ReconciliationLocalDataSource>()));
    gh.lazySingleton<_i402.SimpleCubitInterface>(
      () => _i691.SimpleCubit(),
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i1059.CategoryRepository>(() =>
        _i658.CategoryRepositoryImpl(
            local: gh<_i547.CategoryLocalDataSource>()));
    gh.lazySingleton<_i850.GetMonthlySummaryUseCase>(() =>
        _i850.GetMonthlySummaryUseCase(gh<_i1027.TransactionRepository>()));
    gh.lazySingleton<_i857.CommentRepository>(
        () => _i536.CommentRepositoryImpl(remote: gh<_i130.CommentRemote>()));
    gh.lazySingleton<_i446.GetReconciliationHistoryUseCase>(() =>
        _i446.GetReconciliationHistoryUseCase(
            gh<_i944.ReconciliationRepository>()));
    gh.factory<_i730.CommentController>(
        () => _i730.CommentController(gh<_i670.CommentRepository>()));
    gh.lazySingleton<_i580.CrashLogRemote>(
        () => _i580.CrashLogRemote(gh<_i361.Dio>(instanceName: 'baseDio')));
    gh.lazySingleton<_i857.WalletRepository>(() =>
        _i589.WalletRepositoryImpl(local: gh<_i1058.WalletLocalDataSource>()));
    gh.lazySingleton<_i192.BudgetRepository>(() =>
        _i1007.BudgetRepositoryImpl(local: gh<_i595.BudgetLocalDataSource>()));
    gh.lazySingleton<_i685.CreateBudgetUseCase>(
        () => _i685.CreateBudgetUseCase(gh<_i192.BudgetRepository>()));
    gh.lazySingleton<_i46.DeleteBudgetUseCase>(
        () => _i46.DeleteBudgetUseCase(gh<_i192.BudgetRepository>()));
    gh.lazySingleton<_i807.GetBudgetsUseCase>(
        () => _i807.GetBudgetsUseCase(gh<_i192.BudgetRepository>()));
    gh.lazySingleton<_i205.UpdateBudgetLimitUseCase>(
        () => _i205.UpdateBudgetLimitUseCase(gh<_i192.BudgetRepository>()));
    gh.lazySingleton<_i1058.GetBudgetStatsUseCase>(
        () => _i1058.GetBudgetStatsUseCase(
              gh<_i192.BudgetRepository>(),
              gh<_i1027.TransactionRepository>(),
            ));
    gh.lazySingleton<_i80.ResetBudgetUseCase>(() => _i80.ResetBudgetUseCase(
          gh<_i192.BudgetRepository>(),
          gh<_i685.CreateBudgetUseCase>(),
        ));
    gh.lazySingleton<_i169.GetCategorySpendingUseCase>(
        () => _i169.GetCategorySpendingUseCase(
              gh<_i1027.TransactionRepository>(),
              gh<_i1059.CategoryRepository>(),
            ));
    gh.lazySingleton<_i370.CreateCategoryUseCase>(
        () => _i370.CreateCategoryUseCase(gh<_i1059.CategoryRepository>()));
    gh.lazySingleton<_i1057.DeleteCategoryUseCase>(
        () => _i1057.DeleteCategoryUseCase(gh<_i1059.CategoryRepository>()));
    gh.lazySingleton<_i224.GetCategoriesUseCase>(
        () => _i224.GetCategoriesUseCase(gh<_i1059.CategoryRepository>()));
    gh.lazySingleton<_i397.GetCategoryGroupsUseCase>(
        () => _i397.GetCategoryGroupsUseCase(gh<_i1059.CategoryRepository>()));
    gh.lazySingleton<_i110.ToggleCategoryEnabledUseCase>(() =>
        _i110.ToggleCategoryEnabledUseCase(gh<_i1059.CategoryRepository>()));
    gh.factory<_i402.BudgetController>(() => _i402.BudgetController(
          gh<_i1058.GetBudgetStatsUseCase>(),
          gh<_i685.CreateBudgetUseCase>(),
          gh<_i205.UpdateBudgetLimitUseCase>(),
          gh<_i80.ResetBudgetUseCase>(),
          gh<_i46.DeleteBudgetUseCase>(),
        ));
    gh.lazySingleton<_i971.HomeController>(() => _i971.HomeController(
          gh<_i269.HomeRepository>(),
          gh<_i727.HomeCoordinator>(),
        ));
    gh.lazySingleton<_i195.UndoReconciliationUseCase>(
        () => _i195.UndoReconciliationUseCase(
              gh<_i944.ReconciliationRepository>(),
              gh<_i1027.TransactionRepository>(),
            ));
    gh.lazySingleton<_i473.CrashLogRepository>(
        () => _i689.CrashLogRepositoryImpl(gh<_i580.CrashLogRemote>()));
    gh.lazySingleton<_i892.UploadPendingCrashLogsUseCase>(() =>
        _i892.UploadPendingCrashLogsUseCase(gh<_i473.CrashLogRepository>()));
    gh.lazySingleton<_i167.GetWalletBalancesUseCase>(
        () => _i167.GetWalletBalancesUseCase(
              gh<_i572.WalletRepository>(),
              gh<_i1027.TransactionRepository>(),
            ));
    gh.lazySingleton<_i105.GetWalletBookBalanceUseCase>(
        () => _i105.GetWalletBookBalanceUseCase(
              gh<_i572.WalletRepository>(),
              gh<_i1027.TransactionRepository>(),
            ));
    gh.lazySingleton<_i804.PerformReconciliationUseCase>(
        () => _i804.PerformReconciliationUseCase(
              gh<_i167.GetWalletBalancesUseCase>(),
              gh<_i1027.TransactionRepository>(),
              gh<_i944.ReconciliationRepository>(),
            ));
    gh.factory<_i229.WalletController>(() => _i229.WalletController(
          gh<_i572.WalletRepository>(),
          gh<_i1027.TransactionRepository>(),
          gh<_i105.GetWalletBookBalanceUseCase>(),
        ));
    gh.lazySingleton<_i28.CreateTransactionUseCase>(
        () => _i28.CreateTransactionUseCase(
              gh<_i1027.TransactionRepository>(),
              gh<_i192.BudgetRepository>(),
              gh<_i105.GetWalletBookBalanceUseCase>(),
            ));
    gh.factory<_i353.ReportController>(() => _i353.ReportController(
          gh<_i169.GetCategorySpendingUseCase>(),
          gh<_i850.GetMonthlySummaryUseCase>(),
        ));
    gh.lazySingleton<_i627.CreateTransferUseCase>(
        () => _i627.CreateTransferUseCase(
              gh<_i1027.TransactionRepository>(),
              gh<_i105.GetWalletBookBalanceUseCase>(),
            ));
    gh.factory<_i700.TransactionController>(() => _i700.TransactionController(
          gh<_i1027.TransactionRepository>(),
          gh<_i167.GetWalletBalancesUseCase>(),
        ));
    gh.factory<_i1051.ReconciliationController>(
        () => _i1051.ReconciliationController(
              gh<_i167.GetWalletBalancesUseCase>(),
              gh<_i804.PerformReconciliationUseCase>(),
              gh<_i195.UndoReconciliationUseCase>(),
              gh<_i446.GetReconciliationHistoryUseCase>(),
            ));
  }
}
