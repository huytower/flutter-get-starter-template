import 'package:auto_route/auto_route.dart';

import '../../features/profile/presentation/pages/terms_of_service_page.dart';
import 'domain_router.gr.dart';

@AutoRouterConfig()
class DomainRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(page: TermsOfServiceRoute.page)];
}
