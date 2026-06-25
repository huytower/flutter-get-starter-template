import 'package:injectable/injectable.dart';

import '../../../../core/config/retrofit/response/body/res_body_model.dart';
import '../../../../domain/entities/dashboard/dashboard_entity.dart';
import '../../../models/dashboard/dashboard_model.dart';
import 'dashboard_remote_datasource.dart';

/// Dashboard Remote Data Source Implementation - Data Layer
@LazySingleton(as: DashboardRemoteDataSource)
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl();

  @override
  Future<DashboardEntity> fetchDashboardData() async {
    // Simulate http delay
    await Future.delayed(const Duration(milliseconds: 500));

    final random = DateTime.now().millisecondsSinceEpoch;
    final titles = [
      'Dashboard Overview',
      'System Performance',
      'User Statistics',
      'Real-time Updates',
    ];

    // Mocking a standard enveloped JSON response from a server
    final mockJsonResponse = {
      "status": true,
      "message": "Dashboard data fetched successfully",
      "data": {
        "title": titles[random % titles.length],
        "description":
            'This is the latest dashboard data from the remote server (mocked via CcResBodyModel).',
        "itemCount": random % 1000,
        "lastUpdated": DateTime.now().toIso8601String(),
      },
      "total": 1,
    };

    // Demonstrating the use of ResBodyModel for parsing
    // In a real Retrofit implementation, the CcResponseInterceptor would handle this peeling,
    // but we can also use it manually for robust parsing.
    final body = ResBodyModel<DashboardModel>.fromJson(mockJsonResponse);
    body.flatMapToList((json) => DashboardModel.fromJson(json));

    if (body.isSuccess && body.firstElement != null) {
      return body.firstElement!;
    } else {
      throw Exception(
        body.message.isNotEmpty
            ? body.message
            : 'Failed to fetch dashboard data',
      );
    }
  }

  @override
  Future<DashboardEntity> updateDashboardData(
    DashboardEntity dashboardData,
  ) async {
    // Simulate http delay
    await Future.delayed(const Duration(milliseconds: 300));
    return dashboardData.copyWith(lastUpdated: DateTime.now());
  }
}
