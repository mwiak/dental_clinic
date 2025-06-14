import 'dart:convert';
import 'dart:io';

import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/public_methods/datetime_methods.dart';
import 'package:dental_clinic/view_model/navigationService.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BackupProvider extends ChangeNotifier {
  String activeDirectory = '';

  BackupProvider() {
    getActiveDirectory();
  }

  Future<void> pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      await makeDirPreference(selectedDirectory);
      getActiveDirectory();
      // You can now use this path to read/write files
    } else {
      print('no dir found');
      return null;
    }
  }

  void startBackup(String dir) async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'archive.db');

    File database = File(path);
    String now = currentDateStampToString(DateTime.now());

    try {
      final targetDir = Directory(join(dir, now));
      if (!(await targetDir.exists())) {
        await targetDir.create(
            recursive:
                true); // This ensures all intermediate folders are created
      }
      await database.copy(join(dir, now, 'archive.db'));
      showBarFromProvider(
          'تم إنشاء النسخة في مجلد النسخ الاحتياطي', InfoBarSeverity.success);
    } catch (e) {
      print(e);
      showBarFromProvider('حدث خطأ', InfoBarSeverity.error);
    }
  }

  Future<void> makeDirPreference(String newDir) async {
    final String appDocDir = await Directory.current.path;
    String jsonPath = join(appDocDir, 'preferences.json');
    final File prefsFile = File(jsonPath);
    Map<String, dynamic> defaultPrefs = {"version": "1", "backup_dir": "no"};
    if (!(await prefsFile.exists())) {
      await prefsFile.writeAsString(jsonEncode(defaultPrefs), flush: true);
    } else {
      String jsonString = await prefsFile.readAsString();
      Map response = await jsonDecode(jsonString);
      response['backup_dir'] = newDir;
      String newData = jsonEncode(response);
      await prefsFile.writeAsString(newData, flush: true);
    }
  }

  void newBackup() async {
    Directory path = Directory(activeDirectory);
    if (await path.exists()) {
      startBackup(activeDirectory);
    } else {
      showBarFromProvider(
          'المجلد غير موجود قم ياختيار مجلد آخر', InfoBarSeverity.warning);
    }
  }

  void getActiveDirectory() async {
    final String appDocDir = await Directory.current.path;
    print(appDocDir);
    String jsonPath = join(appDocDir, 'preferences.json');
    final File prefsFile = File(jsonPath);

    if (await prefsFile.exists()) {
      String dataString = await prefsFile.readAsString();
      print(dataString);

      Map dataMap = jsonDecode(dataString);
      print(dataMap["backup_dir"]);
      String dir = dataMap['backup_dir'];
      activeDirectory = dir;
      notifyListeners();
      print(activeDirectory);
    } else {
      Map<String, dynamic> defaultPrefs = {"version": "1", "backup_dir": ""};
      await prefsFile.writeAsString(jsonEncode(defaultPrefs), flush: true);
      activeDirectory = 'غير محدد';
      notifyListeners();
      print(activeDirectory);
    }
  }

  void showBarFromProvider(String message, var type) {
    BuildContext? context = NavigationService.overlayContext;
    if (context != null) {
      showBar(context!, message, type);
    } else {
      print('null');
    }
  }
}
