import 'package:dental_clinic/database/sqflite.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ShortcutsProvider extends ChangeNotifier {
  List shortcuts = [];
  SqlDb dataHelper = SqlDb();

  Future<void> getALlShortcuts() async {
    List data = await dataHelper.readData('''SELECT * FROM shortcuts''');

    shortcuts = data;
    notifyListeners();
  }

  Future<void> addShortcut(String value, String category) async {
    int response = await dataHelper.insertData(
        '''INSERT INTO shortcuts (value,category) VALUES ('$value','$category')''');

    await getALlShortcuts();

    notifyListeners();
  }
}
