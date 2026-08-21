// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:cc_bridge/export_cc_bridge.dart' as _i727;
import 'package:cc_micro_features/features/auth/domain/usecases/delete_account_usecase.dart'
    as _i308;
import 'package:data_config/core/util/firestore_sync_service.dart' as _i954;
import 'package:dio/dio.dart' as _i361;
import 'package:domain_features/core/helper/ai_advice_cache_datasource.dart'
    as _i994;
import 'package:domain_features/core/helper/ai_fallback_preference_datasource.dart'
    as _i967;
import 'package:domain_features/export_domain_features.dart' as _i857;
import 'package:domain_features/features/budget_allocation/presentation/get_x/budget_allocation_controller.dart'
    as _i451;
import 'package:domain_features/features/budget_limit/data/datasources/budget_limit_sync_datasource.dart'
    as _i540;
import 'package:domain_features/features/budget_limit/data/datasources/local/budget_limit_local_datasource.dart'
    as _i585;
import 'package:domain_features/features/budget_limit/data/repositories/budget_limit_repository_impl.dart'
    as _i150;
import 'package:domain_features/features/budget_limit/domain/repositories/budget_limit_repository.dart'
    as _i544;
import 'package:domain_features/features/budget_limit/domain/usecases/create_budget_limit_usecase.dart'
    as _i77;
import 'package:domain_features/features/budget_limit/domain/usecases/delete_budget_limit_usecase.dart'
    as _i106;
import 'package:domain_features/features/budget_limit/domain/usecases/get_budget_anomalies_usecase.dart'
    as _i463;
import 'package:domain_features/features/budget_limit/domain/usecases/get_budget_insights_usecase.dart'
    as _i206;
import 'package:domain_features/features/budget_limit/domain/usecases/get_budget_limit_stats_usecase.dart'
    as _i743;
import 'package:domain_features/features/budget_limit/domain/usecases/get_budget_limits_usecase.dart'
    as _i847;
import 'package:domain_features/features/budget_limit/domain/usecases/get_budget_over_limit_count_usecase.dart'
    as _i467;
import 'package:domain_features/features/budget_limit/domain/usecases/get_category_average_monthly_spend_usecase.dart'
    as _i393;
import 'package:domain_features/features/budget_limit/domain/usecases/sort_budget_limits_by_limit_usecase.dart'
    as _i250;
import 'package:domain_features/features/budget_limit/domain/usecases/sort_budget_limits_by_progress_usecase.dart'
    as _i37;
import 'package:domain_features/features/budget_limit/domain/usecases/update_budget_limit_orders_usecase.dart'
    as _i256;
import 'package:domain_features/features/budget_limit/domain/usecases/update_budget_limit_usecase.dart'
    as _i829;
import 'package:domain_features/features/budget_limit/presentation/get_x/budget_limit_controller.dart'
    as _i1003;
import 'package:domain_features/features/category/data/datasources/category_sync_datasource.dart'
    as _i589;
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
import 'package:domain_features/features/category/domain/usecases/update_category_usecase.dart'
    as _i989;
import 'package:domain_features/features/category/export_category.dart'
    as _i1041;
import 'package:domain_features/features/category/presentation/get_x/category_settings_controller.dart'
    as _i174;
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
import 'package:domain_features/features/firestore/financial_data_sync_service.dart'
    as _i963;
import 'package:domain_features/features/guideline/guideline_controller.dart'
    as _i128;
import 'package:domain_features/features/liability/data/datasources/liability_sync_datasource.dart'
    as _i622;
import 'package:domain_features/features/liability/data/datasources/local/liability_local_datasource.dart'
    as _i783;
import 'package:domain_features/features/liability/data/repositories/liability_repository_impl.dart'
    as _i230;
import 'package:domain_features/features/liability/domain/repositories/liability_repository.dart'
    as _i813;
import 'package:domain_features/features/liability/domain/usecases/create_liability_usecase.dart'
    as _i805;
import 'package:domain_features/features/liability/domain/usecases/get_liability_balances_usecase.dart'
    as _i663;
import 'package:domain_features/features/liability/domain/usecases/get_liability_outstanding_balance_usecase.dart'
    as _i834;
import 'package:domain_features/features/liability/domain/usecases/record_liability_payment_usecase.dart'
    as _i941;
import 'package:domain_features/features/liability/domain/usecases/schedule_liability_reminders_usecase.dart'
    as _i934;
import 'package:domain_features/features/liability/presentation/get_x/add_liability_sheet_controller.dart'
    as _i1007;
import 'package:domain_features/features/liability/presentation/get_x/lend_form_controller.dart'
    as _i198;
import 'package:domain_features/features/liability/presentation/get_x/liability_detail_controller.dart'
    as _i849;
import 'package:domain_features/features/liability/presentation/get_x/liability_form_controller.dart'
    as _i279;
import 'package:domain_features/features/liability/presentation/get_x/liability_list_controller.dart'
    as _i971;
import 'package:domain_features/features/notification/domain/usecases/check_audit_reminder_usecase.dart'
    as _i340;
import 'package:domain_features/features/notification/domain/usecases/check_budget_threshold_usecase.dart'
    as _i390;
import 'package:domain_features/features/notification/domain/usecases/check_cloud_backup_reminder_usecase.dart'
    as _i575;
import 'package:domain_features/features/notification/notification_service.dart'
    as _i483;
import 'package:domain_features/features/profile/data/datasources/local/profile_local_datasource.dart'
    as _i755;
import 'package:domain_features/features/profile/data/repositories/profile_repository_impl.dart'
    as _i609;
import 'package:domain_features/features/profile/domain/repositories/profile_repository.dart'
    as _i270;
import 'package:domain_features/features/profile/domain/usecases/get_profile_settings_usecase.dart'
    as _i569;
import 'package:domain_features/features/profile/domain/usecases/update_profile_settings_usecase.dart'
    as _i220;
import 'package:domain_features/features/profile/presentation/get_x/profile_controller.dart'
    as _i920;
import 'package:domain_features/features/reconciliation/data/datasources/local/reconciliation_local_datasource.dart'
    as _i896;
import 'package:domain_features/features/reconciliation/data/datasources/reconciliation_sync_datasource.dart'
    as _i945;
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
import 'package:domain_features/features/report/domain/usecases/generate_ai_financial_advice_usecase.dart'
    as _i436;
import 'package:domain_features/features/report/domain/usecases/get_category_spending_usecase.dart'
    as _i169;
import 'package:domain_features/features/report/domain/usecases/get_financial_runway_usecase.dart'
    as _i701;
import 'package:domain_features/features/report/domain/usecases/get_investment_trend_usecase.dart'
    as _i229;
import 'package:domain_features/features/report/domain/usecases/get_loan_trend_usecase.dart'
    as _i224;
import 'package:domain_features/features/report/domain/usecases/get_monthly_summary_usecase.dart'
    as _i850;
import 'package:domain_features/features/report/domain/usecases/get_trend_data_usecase.dart'
    as _i951;
import 'package:domain_features/features/report/presentation/get_x/report_controller.dart'
    as _i353;
import 'package:domain_features/features/transaction/data/datasources/local/transaction_local_datasource.dart'
    as _i648;
import 'package:domain_features/features/transaction/data/datasources/transaction_sync_datasource.dart'
    as _i784;
import 'package:domain_features/features/transaction/data/repositories/transaction_repository_impl.dart'
    as _i1032;
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart'
    as _i1027;
import 'package:domain_features/features/transaction/domain/usecases/create_investment_transaction_usecase.dart'
    as _i240;
import 'package:domain_features/features/transaction/domain/usecases/create_transaction_usecase.dart'
    as _i28;
import 'package:domain_features/features/transaction/domain/usecases/get_month_to_date_cash_flow_usecase.dart'
    as _i774;
import 'package:domain_features/features/transaction/domain/usecases/parse_quick_entry_usecase.dart'
    as _i121;
import 'package:domain_features/features/transaction/domain/usecases/update_transaction_usecase.dart'
    as _i756;
import 'package:domain_features/features/transaction/presentation/get_x/category_selection_controller.dart'
    as _i615;
import 'package:domain_features/features/transaction/presentation/get_x/expense_form_controller.dart'
    as _i754;
import 'package:domain_features/features/transaction/presentation/get_x/income_form_controller.dart'
    as _i594;
import 'package:domain_features/features/transaction/presentation/get_x/investment_form_controller.dart'
    as _i135;
import 'package:domain_features/features/transaction/presentation/get_x/transaction_controller.dart'
    as _i700;
import 'package:domain_features/features/user_level/domain/usecases/get_user_level_status_usecase.dart'
    as _i585;
import 'package:domain_features/features/user_level/presentation/get_x/user_level_controller.dart'
    as _i356;
import 'package:domain_features/features/wallet/data/datasources/local/wallet_local_datasource.dart'
    as _i1058;
import 'package:domain_features/features/wallet/data/datasources/wallet_sync_datasource.dart'
    as _i156;
import 'package:domain_features/features/wallet/data/repositories/wallet_repository_impl.dart'
    as _i589;
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart'
    as _i572;
import 'package:domain_features/features/wallet/domain/usecases/get_investment_roi_usecase.dart'
    as _i845;
import 'package:domain_features/features/wallet/domain/usecases/get_wallet_balances_usecase.dart'
    as _i167;
import 'package:domain_features/features/wallet/domain/usecases/get_wallet_book_balance_usecase.dart'
    as _i105;
import 'package:domain_features/features/wallet/presentation/get_x/add_investment_sheet_controller.dart'
    as _i797;
import 'package:domain_features/features/wallet/presentation/get_x/add_liquid_sheet_controller.dart'
    as _i95;
import 'package:domain_features/features/wallet/presentation/get_x/wallet_controller.dart'
    as _i229;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;

class DomainFeaturesPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i594.IncomeFormController>(() => _i594.IncomeFormController());
    gh.lazySingleton<_i994.AiAdviceCacheDataSource>(
        () => _i994.AiAdviceCacheDataSource());
    gh.lazySingleton<_i967.AiFallbackPreferenceDataSource>(
        () => _i967.AiFallbackPreferenceDataSource());
    gh.lazySingleton<_i585.BudgetLimitLocalDataSource>(
        () => _i585.BudgetLimitLocalDataSource());
    gh.lazySingleton<_i250.SortBudgetLimitsByLimitUseCase>(
        () => _i250.SortBudgetLimitsByLimitUseCase());
    gh.lazySingleton<_i37.SortBudgetLimitsByProgressUseCase>(
        () => _i37.SortBudgetLimitsByProgressUseCase());
    gh.lazySingleton<_i547.CategoryLocalDataSource>(
        () => _i547.CategoryLocalDataSource());
    gh.lazySingleton<_i1004.AdvanceBloc>(
      () => _i1004.AdvanceBloc(),
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i783.LiabilityLocalDatasource>(
        () => _i783.LiabilityLocalDatasource());
    gh.lazySingleton<_i198.LendFormController>(
        () => _i198.LendFormController());
    gh.lazySingleton<_i279.LiabilityFormController>(
        () => _i279.LiabilityFormController());
    gh.lazySingleton<_i483.NotificationService>(
        () => _i483.NotificationService());
    gh.lazySingleton<_i755.ProfileLocalDataSource>(
        () => _i755.ProfileLocalDataSource());
    gh.lazySingleton<_i896.ReconciliationLocalDataSource>(
        () => _i896.ReconciliationLocalDataSource());
    gh.lazySingleton<_i648.TransactionLocalDataSource>(
        () => _i648.TransactionLocalDataSource());
    gh.lazySingleton<_i1058.WalletLocalDataSource>(
        () => _i1058.WalletLocalDataSource());
    gh.lazySingleton<_i934.ScheduleLiabilityRemindersUseCase>(() =>
        _i934.ScheduleLiabilityRemindersUseCase(
            gh<_i483.NotificationService>()));
    gh.factory<_i540.BudgetLimitSyncDataSource>(
        () => _i540.BudgetLimitSyncDataSource(
              gh<_i954.FirestoreSyncService>(),
              gh<_i727.SessionContract>(),
            ));
    gh.factory<_i589.CategorySyncDataSource>(() => _i589.CategorySyncDataSource(
          gh<_i954.FirestoreSyncService>(),
          gh<_i727.SessionContract>(),
        ));
    gh.factory<_i622.LiabilitySyncDatasource>(
        () => _i622.LiabilitySyncDatasource(
              gh<_i954.FirestoreSyncService>(),
              gh<_i727.SessionContract>(),
            ));
    gh.factory<_i945.ReconciliationSyncDataSource>(
        () => _i945.ReconciliationSyncDataSource(
              gh<_i954.FirestoreSyncService>(),
              gh<_i727.SessionContract>(),
            ));
    gh.factory<_i784.TransactionSyncDataSource>(
        () => _i784.TransactionSyncDataSource(
              gh<_i954.FirestoreSyncService>(),
              gh<_i727.SessionContract>(),
            ));
    gh.factory<_i156.WalletSyncDataSource>(() => _i156.WalletSyncDataSource(
          gh<_i954.FirestoreSyncService>(),
          gh<_i727.SessionContract>(),
        ));
    gh.lazySingleton<_i130.CommentRemote>(
        () => _i130.CommentRemote(gh<_i361.Dio>(instanceName: 'baseDio')));
    gh.lazySingleton<_i402.SimpleCubitInterface>(
      () => _i691.SimpleCubit(),
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i963.FinancialDataSyncService>(
        () => _i963.FinancialDataSyncService(
              gh<_i954.FirestoreSyncService>(),
              gh<_i727.SessionContract>(),
              gh<_i161.InternetConnection>(),
              gh<_i156.WalletSyncDataSource>(),
              gh<_i784.TransactionSyncDataSource>(),
              gh<_i540.BudgetLimitSyncDataSource>(),
              gh<_i945.ReconciliationSyncDataSource>(),
              gh<_i589.CategorySyncDataSource>(),
              gh<_i622.LiabilitySyncDatasource>(),
            ));
    gh.lazySingleton<_i544.BudgetLimitRepository>(
        () => _i150.BudgetLimitRepositoryImpl(
              local: gh<_i585.BudgetLimitLocalDataSource>(),
              syncService: gh<_i963.FinancialDataSyncService>(),
            ));
    gh.lazySingleton<_i77.CreateBudgetLimitUseCase>(
        () => _i77.CreateBudgetLimitUseCase(gh<_i544.BudgetLimitRepository>()));
    gh.lazySingleton<_i106.DeleteBudgetLimitUseCase>(() =>
        _i106.DeleteBudgetLimitUseCase(gh<_i544.BudgetLimitRepository>()));
    gh.lazySingleton<_i847.GetBudgetLimitsUseCase>(
        () => _i847.GetBudgetLimitsUseCase(gh<_i544.BudgetLimitRepository>()));
    gh.lazySingleton<_i256.UpdateBudgetLimitOrdersUseCase>(() =>
        _i256.UpdateBudgetLimitOrdersUseCase(
            gh<_i544.BudgetLimitRepository>()));
    gh.lazySingleton<_i829.UpdateBudgetLimitUseCase>(() =>
        _i829.UpdateBudgetLimitUseCase(gh<_i544.BudgetLimitRepository>()));
    gh.lazySingleton<_i813.LiabilityRepository>(
        () => _i230.LiabilityRepositoryImpl(
              local: gh<_i783.LiabilityLocalDatasource>(),
              syncService: gh<_i963.FinancialDataSyncService>(),
            ));
    gh.lazySingleton<_i857.CommentRepository>(
        () => _i536.CommentRepositoryImpl(remote: gh<_i130.CommentRemote>()));
    gh.factory<_i730.CommentController>(
        () => _i730.CommentController(gh<_i670.CommentRepository>()));
    gh.lazySingleton<_i580.CrashLogRemote>(
        () => _i580.CrashLogRemote(gh<_i361.Dio>(instanceName: 'baseDio')));
    gh.lazySingleton<_i270.ProfileRepository>(() =>
        _i609.ProfileRepositoryImpl(local: gh<_i755.ProfileLocalDataSource>()));
    gh.lazySingleton<_i572.WalletRepository>(() => _i589.WalletRepositoryImpl(
          local: gh<_i1058.WalletLocalDataSource>(),
          sync: gh<_i156.WalletSyncDataSource>(),
        ));
    gh.lazySingleton<_i857.TransactionRepository>(
        () => _i1032.TransactionRepositoryImpl(
              local: gh<_i648.TransactionLocalDataSource>(),
              syncService: gh<_i857.FinancialDataSyncService>(),
            ));
    gh.factory<_i279.LoanInstallmentDraft>(
        () => _i279.LoanInstallmentDraft(gh<DateTime>()));
    gh.lazySingleton<_i944.ReconciliationRepository>(
        () => _i513.ReconciliationRepositoryImpl(
              local: gh<_i896.ReconciliationLocalDataSource>(),
              syncService: gh<_i963.FinancialDataSyncService>(),
            ));
    gh.lazySingleton<_i1059.CategoryRepository>(
        () => _i658.CategoryRepositoryImpl(
              local: gh<_i547.CategoryLocalDataSource>(),
              syncService: gh<_i963.FinancialDataSyncService>(),
            ));
    gh.lazySingleton<_i169.GetCategorySpendingUseCase>(
        () => _i169.GetCategorySpendingUseCase(
              gh<_i1027.TransactionRepository>(),
              gh<_i1059.CategoryRepository>(),
            ));
    gh.lazySingleton<_i951.GetTrendDataUseCase>(() => _i951.GetTrendDataUseCase(
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
    gh.lazySingleton<_i989.UpdateCategoryUseCase>(
        () => _i989.UpdateCategoryUseCase(gh<_i1059.CategoryRepository>()));
    gh.lazySingleton<_i195.UndoReconciliationUseCase>(
        () => _i195.UndoReconciliationUseCase(
              gh<_i944.ReconciliationRepository>(),
              gh<_i1027.TransactionRepository>(),
            ));
    gh.lazySingleton<_i473.CrashLogRepository>(
        () => _i689.CrashLogRepositoryImpl(gh<_i580.CrashLogRemote>()));
    gh.lazySingleton<_i569.GetProfileSettingsUseCase>(
        () => _i569.GetProfileSettingsUseCase(gh<_i270.ProfileRepository>()));
    gh.lazySingleton<_i220.UpdateProfileSettingsUseCase>(() =>
        _i220.UpdateProfileSettingsUseCase(gh<_i270.ProfileRepository>()));
    gh.lazySingleton<_i575.CheckCloudBackupReminderUseCase>(
        () => _i575.CheckCloudBackupReminderUseCase(
              gh<_i270.ProfileRepository>(),
              gh<_i727.SessionContract>(),
              gh<_i483.NotificationService>(),
            ));
    gh.lazySingleton<_i892.UploadPendingCrashLogsUseCase>(() =>
        _i892.UploadPendingCrashLogsUseCase(gh<_i473.CrashLogRepository>()));
    gh.lazySingleton<_i340.CheckAuditReminderUseCase>(
        () => _i340.CheckAuditReminderUseCase(
              gh<_i270.ProfileRepository>(),
              gh<_i944.ReconciliationRepository>(),
              gh<_i483.NotificationService>(),
            ));
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
    gh.lazySingleton<_i393.GetCategoryAverageMonthlySpendUseCase>(() =>
        _i393.GetCategoryAverageMonthlySpendUseCase(
            gh<_i1027.TransactionRepository>()));
    gh.lazySingleton<_i229.GetInvestmentTrendUseCase>(() =>
        _i229.GetInvestmentTrendUseCase(gh<_i1027.TransactionRepository>()));
    gh.lazySingleton<_i224.GetLoanTrendUseCase>(
        () => _i224.GetLoanTrendUseCase(gh<_i1027.TransactionRepository>()));
    gh.lazySingleton<_i850.GetMonthlySummaryUseCase>(() =>
        _i850.GetMonthlySummaryUseCase(gh<_i1027.TransactionRepository>()));
    gh.lazySingleton<_i774.GetMonthToDateCashFlowUseCase>(() =>
        _i774.GetMonthToDateCashFlowUseCase(
            gh<_i1027.TransactionRepository>()));
    gh.lazySingleton<_i845.GetInvestmentRoiUseCase>(() =>
        _i845.GetInvestmentRoiUseCase(gh<_i1027.TransactionRepository>()));
    gh.factory<_i754.ExpenseFormController>(
        () => _i754.ExpenseFormController(gh<_i1027.TransactionRepository>()));
    gh.lazySingleton<_i240.CreateInvestmentTransactionUseCase>(
        () => _i240.CreateInvestmentTransactionUseCase(
              gh<_i1027.TransactionRepository>(),
              gh<_i572.WalletRepository>(),
              gh<_i105.GetWalletBookBalanceUseCase>(),
            ));
    gh.lazySingleton<_i28.CreateTransactionUseCase>(
        () => _i28.CreateTransactionUseCase(
              gh<_i1027.TransactionRepository>(),
              gh<_i572.WalletRepository>(),
              gh<_i105.GetWalletBookBalanceUseCase>(),
            ));
    gh.lazySingleton<_i446.GetReconciliationHistoryUseCase>(() =>
        _i446.GetReconciliationHistoryUseCase(
            gh<_i944.ReconciliationRepository>()));
    gh.lazySingleton<_i804.PerformReconciliationUseCase>(
        () => _i804.PerformReconciliationUseCase(
              gh<_i167.GetWalletBalancesUseCase>(),
              gh<_i1027.TransactionRepository>(),
              gh<_i944.ReconciliationRepository>(),
            ));
    gh.lazySingleton<_i121.ParseQuickEntryUseCase>(
        () => _i121.ParseQuickEntryUseCase(gh<_i224.GetCategoriesUseCase>()));
    gh.lazySingleton<_i663.GetLiabilityBalancesUseCase>(
        () => _i663.GetLiabilityBalancesUseCase(
              gh<_i813.LiabilityRepository>(),
              gh<_i1027.TransactionRepository>(),
            ));
    gh.lazySingleton<_i834.GetLiabilityOutstandingBalanceUseCase>(
        () => _i834.GetLiabilityOutstandingBalanceUseCase(
              gh<_i813.LiabilityRepository>(),
              gh<_i1027.TransactionRepository>(),
            ));
    gh.lazySingleton<_i467.GetBudgetOverLimitCountUseCase>(
        () => _i467.GetBudgetOverLimitCountUseCase(
              gh<_i544.BudgetLimitRepository>(),
              gh<_i1027.TransactionRepository>(),
            ));
    gh.lazySingleton<_i743.GetBudgetLimitStatsUseCase>(
        () => _i743.GetBudgetLimitStatsUseCase(
              gh<_i544.BudgetLimitRepository>(),
              gh<_i1027.TransactionRepository>(),
              gh<_i1059.CategoryRepository>(),
            ));
    gh.factory<_i615.CategorySelectionController>(() =>
        _i615.CategorySelectionController(gh<_i224.GetCategoriesUseCase>()));
    gh.lazySingleton<_i756.UpdateTransactionUseCase>(
        () => _i756.UpdateTransactionUseCase(
              gh<_i1027.TransactionRepository>(),
              gh<_i105.GetWalletBookBalanceUseCase>(),
            ));
    gh.lazySingleton<_i941.RecordLiabilityPaymentUseCase>(
        () => _i941.RecordLiabilityPaymentUseCase(
              gh<_i813.LiabilityRepository>(),
              gh<_i1027.TransactionRepository>(),
              gh<_i834.GetLiabilityOutstandingBalanceUseCase>(),
              gh<_i105.GetWalletBookBalanceUseCase>(),
            ));
    gh.factory<_i174.CategorySettingsController>(
        () => _i174.CategorySettingsController(
              gh<_i397.GetCategoryGroupsUseCase>(),
              gh<_i224.GetCategoriesUseCase>(),
              gh<_i110.ToggleCategoryEnabledUseCase>(),
              gh<_i569.GetProfileSettingsUseCase>(),
              gh<_i220.UpdateProfileSettingsUseCase>(),
            ));
    gh.lazySingleton<_i1003.BudgetLimitController>(
        () => _i1003.BudgetLimitController(
              gh<_i743.GetBudgetLimitStatsUseCase>(),
              gh<_i77.CreateBudgetLimitUseCase>(),
              gh<_i829.UpdateBudgetLimitUseCase>(),
              gh<_i256.UpdateBudgetLimitOrdersUseCase>(),
              gh<_i106.DeleteBudgetLimitUseCase>(),
            ));
    gh.factory<_i135.InvestmentFormController>(
        () => _i135.InvestmentFormController(
              gh<_i1041.GetCategoriesUseCase>(),
              gh<_i569.GetProfileSettingsUseCase>(),
              gh<_i240.CreateInvestmentTransactionUseCase>(),
            ));
    gh.lazySingleton<_i229.WalletController>(() => _i229.WalletController(
          gh<_i572.WalletRepository>(),
          gh<_i1027.TransactionRepository>(),
          gh<_i105.GetWalletBookBalanceUseCase>(),
          gh<_i845.GetInvestmentRoiUseCase>(),
          gh<_i569.GetProfileSettingsUseCase>(),
        ));
    gh.lazySingleton<_i701.GetFinancialRunwayUseCase>(
        () => _i701.GetFinancialRunwayUseCase(
              gh<_i572.WalletRepository>(),
              gh<_i1027.TransactionRepository>(),
              gh<_i167.GetWalletBalancesUseCase>(),
              gh<_i1059.CategoryRepository>(),
              gh<_i544.BudgetLimitRepository>(),
            ));
    gh.lazySingleton<_i805.CreateLiabilityUseCase>(
        () => _i805.CreateLiabilityUseCase(
              gh<_i813.LiabilityRepository>(),
              gh<_i1027.TransactionRepository>(),
              gh<_i105.GetWalletBookBalanceUseCase>(),
            ));
    gh.lazySingleton<_i585.GetUserLevelStatusUseCase>(
        () => _i585.GetUserLevelStatusUseCase(
              gh<_i446.GetReconciliationHistoryUseCase>(),
              gh<_i544.BudgetLimitRepository>(),
              gh<_i1027.TransactionRepository>(),
              gh<_i270.ProfileRepository>(),
            ));
    gh.lazySingleton<_i971.LiabilityListController>(
        () => _i971.LiabilityListController(
              gh<_i663.GetLiabilityBalancesUseCase>(),
              gh<_i813.LiabilityRepository>(),
            ));
    gh.lazySingleton<_i463.GetBudgetAnomaliesUseCase>(
        () => _i463.GetBudgetAnomaliesUseCase(
              gh<_i743.GetBudgetLimitStatsUseCase>(),
              gh<_i1027.TransactionRepository>(),
            ));
    gh.lazySingleton<_i390.CheckBudgetThresholdUseCase>(
        () => _i390.CheckBudgetThresholdUseCase(
              gh<_i743.GetBudgetLimitStatsUseCase>(),
              gh<_i483.NotificationService>(),
            ));
    gh.factory<_i1007.AddLiabilitySheetController>(
        () => _i1007.AddLiabilitySheetController(
              gh<_i1041.GetCategoriesUseCase>(),
              gh<_i569.GetProfileSettingsUseCase>(),
              gh<_i805.CreateLiabilityUseCase>(),
              gh<_i229.WalletController>(),
              gh<_i663.GetLiabilityBalancesUseCase>(),
            ));
    gh.factory<_i849.LiabilityDetailController>(
        () => _i849.LiabilityDetailController(
              gh<_i813.LiabilityRepository>(),
              gh<_i1027.TransactionRepository>(),
              gh<_i941.RecordLiabilityPaymentUseCase>(),
            ));
    gh.lazySingleton<_i356.UserLevelController>(
        () => _i356.UserLevelController(gh<_i585.GetUserLevelStatusUseCase>()));
    gh.lazySingleton<_i206.GetBudgetInsightsUseCase>(
        () => _i206.GetBudgetInsightsUseCase(
              gh<_i743.GetBudgetLimitStatsUseCase>(),
              gh<_i774.GetMonthToDateCashFlowUseCase>(),
              gh<_i463.GetBudgetAnomaliesUseCase>(),
            ));
    gh.factory<_i797.AddInvestmentSheetController>(
        () => _i797.AddInvestmentSheetController(
              gh<_i229.WalletController>(),
              gh<_i224.GetCategoriesUseCase>(),
              gh<_i569.GetProfileSettingsUseCase>(),
            ));
    gh.factory<_i700.TransactionController>(() => _i700.TransactionController(
          gh<_i1027.TransactionRepository>(),
          gh<_i167.GetWalletBalancesUseCase>(),
          gh<_i572.WalletRepository>(),
          gh<_i356.UserLevelController>(),
        ));
    gh.lazySingleton<_i436.GenerateAiFinancialAdviceUseCase>(
        () => _i436.GenerateAiFinancialAdviceUseCase(
              gh<_i206.GetBudgetInsightsUseCase>(),
              gh<_i463.GetBudgetAnomaliesUseCase>(),
              gh<_i701.GetFinancialRunwayUseCase>(),
              gh<_i774.GetMonthToDateCashFlowUseCase>(),
              gh<_i994.AiAdviceCacheDataSource>(),
            ));
    gh.lazySingleton<_i128.GuidelineController>(
        () => _i128.GuidelineController(gh<_i356.UserLevelController>()));
    gh.factory<_i353.ReportController>(() => _i353.ReportController(
          gh<_i169.GetCategorySpendingUseCase>(),
          gh<_i701.GetFinancialRunwayUseCase>(),
          gh<_i951.GetTrendDataUseCase>(),
          gh<_i229.GetInvestmentTrendUseCase>(),
          gh<_i224.GetLoanTrendUseCase>(),
          gh<_i572.WalletRepository>(),
          gh<_i356.UserLevelController>(),
          gh<_i436.GenerateAiFinancialAdviceUseCase>(),
          gh<_i994.AiAdviceCacheDataSource>(),
        ));
    gh.lazySingleton<_i920.ProfileController>(() => _i920.ProfileController(
          gh<_i569.GetProfileSettingsUseCase>(),
          gh<_i220.UpdateProfileSettingsUseCase>(),
          gh<_i1041.ToggleCategoryEnabledUseCase>(),
          gh<_i727.SessionContract>(),
          gh<_i727.CcDeviceInfoHelper>(),
          gh<_i727.AuthCoordinator>(),
          gh<_i356.UserLevelController>(),
          gh<_i483.NotificationService>(),
          gh<_i308.DeleteAccountUseCase>(),
        ));
    gh.lazySingleton<_i451.BudgetAllocationController>(
        () => _i451.BudgetAllocationController(
              gh<_i229.WalletController>(),
              gh<_i1003.BudgetLimitController>(),
              gh<_i663.GetLiabilityBalancesUseCase>(),
              gh<_i356.UserLevelController>(),
              gh<_i206.GetBudgetInsightsUseCase>(),
            ));
    gh.factory<_i1051.ReconciliationController>(
        () => _i1051.ReconciliationController(
              gh<_i167.GetWalletBalancesUseCase>(),
              gh<_i804.PerformReconciliationUseCase>(),
              gh<_i195.UndoReconciliationUseCase>(),
              gh<_i446.GetReconciliationHistoryUseCase>(),
              gh<_i356.UserLevelController>(),
            ));
    gh.factory<_i95.AddLiquidSheetController>(
        () => _i95.AddLiquidSheetController(
              gh<_i229.WalletController>(),
              gh<_i224.GetCategoriesUseCase>(),
              gh<_i356.UserLevelController>(),
            ));
  }
}
