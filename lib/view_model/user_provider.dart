import 'package:dental_clinic/model/user_model.dart';
import 'package:dental_clinic/shared/theme.dart';
import 'package:fluent_ui/fluent_ui.dart';

class UserProvider extends ChangeNotifier {
  UserModel userModel = UserModel();

  String name = '';
  String center = '';
  String displayMode = '';

  FluentThemeData themeMode = lightMode;
  Locale language = Locale('en');

  Future<void> getUserData() async {
    List data = await userModel.getUserData();

    name = data[0]['name'];
    center = data[0]['center'];
    language = data[0]['language'] == 'English' ? Locale('en') : Locale('ar');
    themeMode = data[0]['is_dark_mode'] == 1 ? darkMode : lightMode;
    displayMode = data[0]['display_mode'];
    notifyListeners();
  }

  void toggleDark(String val) {
    if (val == 'light') {
      themeMode = lightMode;
      notifyListeners();
    } else if (val == 'dark') {
      themeMode = darkMode;
      notifyListeners();
    } else {}
  }

  void toggleLanguage(String val) {
    if (val == 'English') {
      language = const Locale('en');
      notifyListeners();
    } else if (val == 'Arabic') {
      language = const Locale('ar');
      notifyListeners();
    } else {}
  }

  Future<void> createNewUser(
      String name, String center, String language, bool isDark) async {
    await userModel.createNewUser(name, center, language, isDark);
  }

  Future<void> modifyDark(String val) async {
    if (val == 'light') {
      themeMode = lightMode;
      await userModel.modifyIsDark(false);
      notifyListeners();
    } else if (val == 'dark') {
      themeMode = darkMode;
      await userModel.modifyIsDark(true);
      notifyListeners();
    } else {}
  }

  Future<void> modifyLanguage(String val) async {
    if (val == 'English') {
      language = const Locale('en');
      await userModel.modifyLanguage(val);
      notifyListeners();
    } else if (val == 'Arabic') {
      language = const Locale('ar');
      await userModel.modifyLanguage(val);
      notifyListeners();
    } else {}
  }

  Future<void> modifyDisplayMode(String val) async {
    if (val == 'compact') {
      displayMode = 'compact';
      await userModel.modifyDisplayMode(val);
      notifyListeners();
    } else if (val == 'detailed') {
      displayMode = 'detailed';
      await userModel.modifyDisplayMode(val);
      notifyListeners();
    } else {}
  }
}
