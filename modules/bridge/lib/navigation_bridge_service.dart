abstract class NavigationBridgeService {
  Future<void> initializeUserLevel();
  Future<void> initializeDataServices();
  Future<void> syncAuthenticatedData();
  Future<void> checkReminders();
  Future<void> refreshTab(int index);
}
