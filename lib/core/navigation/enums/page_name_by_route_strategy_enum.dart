/// Define all pages in app, serve for :
/// - Routing
/// - GA4

/// CORE PAGE
enum PageNameByRouteStrategyEnum {
  CUBIT_SIMPLE,
  BLOC_ADVANCE,
  BLOC_SIMPLE,
  GETX_SIMPLE,
  GETX_SIMPLE_V2,
}

String getPageNameByRouteStrategy(PageNameByRouteStrategyEnum pageName) =>
    '/${pageName.name.toLowerCase()}';
