import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AuthPreferenceDataSource {
  static const String _keyIsTermsAccepted = 'is_terms_accepted';

  Future<bool> isTermsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsTermsAccepted) ?? false;
  }

  Future<void> setTermsAccepted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsTermsAccepted, value);
  }
}
