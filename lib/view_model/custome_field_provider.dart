import 'package:dental_clinic/database/sqflite.dart';
import 'package:fluent_ui/fluent_ui.dart';

class CustomFieldProvider extends ChangeNotifier {
  SqlDb dataHelper = SqlDb();

  Future<List> getTreatmentsFields(int input) async {
    List data = await dataHelper.readData(
        ''' SELECT * FROM custom_fields WHERE treatment_type_id = $input''');
    return data;
  }

  Future<List> getImplantsFields(int input) async {
    List data = await dataHelper.readData(
        ''' SELECT * FROM custom_fields_implants WHERE implant_type_id = $input''');
    return data;
  }

  void notify() {
    notifyListeners();
  }
}
