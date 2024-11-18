import 'package:dental_clinic/database/sqflite.dart';

class UserModel {
  SqlDb dataHelper = SqlDb();

  Future<void> createNewUser(
      String name, String center, String language, bool isDark) async {
    await dataHelper.insertData(
        '''INSERT INTO user (name,center,language,is_dark_mode) VALUES ('$name', '$center', '$language',$isDark)''');
  }

  Future<List> getUserData() async {
    List data =
        await dataHelper.readData('''SELECT * FROM user WHERE id = 1 ''');

    return data;
  }

  Future<void> modifyIsDark(bool value) async {
    await dataHelper
        .insertData('''UPDATE user SET is_dark_mode=$value WHERE id = 1 ''');
  }

  Future<void> modifyLanguage(String value) async {
    await dataHelper
        .insertData('''UPDATE user SET language='$value' WHERE id = 1 ''');
  }
}
