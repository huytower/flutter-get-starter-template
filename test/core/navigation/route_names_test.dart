import 'package:bridge/export_bridge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter_template/core/navigation/route_names.dart';

void main() {
  test('paths are snake_case, shell routes come from ShellRoutePaths', () {
    expect(AppRoute.walletDetail.path, '/wallet_detail');
    expect(AppRoute.mainNavigation.path, ShellRoutePaths.mainNavigation);
    expect(AppRoute.login.path, ShellRoutePaths.login);
  });

  test('every route path is unique', () {
    final paths = AppRoute.values.map((r) => r.path).toList();
    expect(paths.toSet(), hasLength(paths.length));
  });

  test('parses route keys in any case and separator', () {
    expect(appRouteFromString('wallet detail'), AppRoute.walletDetail);
    expect(appRouteFromString('WALLET-DETAIL'), AppRoute.walletDetail);
    expect(
      appRouteFromString('budget_insights_list'),
      AppRoute.budgetInsightsList,
    );
    expect(appRouteFromString('unknown'), isNull);
    expect(appRouteFromString('  '), isNull);
    expect(exampleRouteFromString('getx simple v2'), ExampleRoute.getxSimpleV2);
  });
}
