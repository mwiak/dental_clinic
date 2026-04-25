import 'package:dental_clinic/database/sqflite.dart';
import 'package:fluent_ui/fluent_ui.dart';

class PregnancyProvider extends ChangeNotifier {
  SqlDb dataHelper = SqlDb();
  List pregnancies = [];
  List sessions = [];

  Future<void> getAllPregnancies(int patientId) async {
    List data = await dataHelper.readData(
        '''SELECT * FROM pregnancies WHERE patient_id = $patientId''');
    pregnancies = data;
    notifyListeners();
  }

  Future<void> addNewPregnancy(
      int patientId, String startDate, String endDate) async {
    int response = await dataHelper.insertData(
        '''INSERT INTO pregnancies (patient_id,start_date,expected_birth_date) VALUES ( $patientId,'$startDate','$endDate'  ) ''');
    if (response > 0) {
      await getAllPregnancies(patientId);
      notifyListeners();
    }
  }

  void deletePregnancy(int id, int patientId) async {
    int response = await dataHelper
        .deleteData('''DELETE FROM pregnancies WHERE id = $id ''');
    if (response > 0) {
      await getAllPregnancies(patientId);
      notifyListeners();
    }
  }

  Future<void> completePregnancy(
      int id, int patientId, String status, String completeDate) async {
    int response = await dataHelper.updateData(
        '''UPDATE pregnancies SET status = '$status', complete_date = '$completeDate' WHERE id = $id ''');
    if (response > 0) {
      await getAllPregnancies(patientId);
      notifyListeners();
    }
  }
  //pregnencies sessions

  Future<void> getPregnancySessions(int id) async {
    List data = await dataHelper
        .readData('''SELECT * FROM sessions WHERE pregnancy_id = $id ''');
    sessions = data;
    notifyListeners();
  }

  Future<void> addNewPregnancySession(
      int patientId, String date, int pregnancy_id) async {
    int response = await dataHelper.insertData(
        '''INSERT INTO sessions (patient_id,date,pregnancy_id) VALUES ( $patientId,'$date',$pregnancy_id) ''');
    if (response > 0) {
      await getPregnancySessions(pregnancy_id);
      notifyListeners();
    }
  }
}
