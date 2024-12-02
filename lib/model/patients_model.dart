import 'package:dental_clinic/database/sqflite.dart';

class PatientsModel {
  SqlDb dataHelper = SqlDb();

  Future<int> addNewPatient(String firstName, String lastName, String age,
      String phone, String date) async {
    int response = await dataHelper.insertData(
        '''INSERT INTO patients (firstname,lastname,age,phone_number,date) VALUES ('$firstName','$lastName','$age','$phone', '$date')  ''');
    return response;
  }

  Future<List> getAllPatients() async {
    List data = await dataHelper
        .readData('''SELECT * FROM patients ORDER BY id DESC ''');
    return data;
  }

  Future<List> getAllPatientsLimited() async {
    List data = await dataHelper
        .readData('''SELECT * FROM patients ORDER BY id DESC LIMIT 500 ''');
    return data;
  }

  Future<List> getAllPatientsSearched(String input) async {
    List data = await dataHelper.readData(
        '''SELECT * FROM patients  WHERE firstname || ' ' || lastname LIKE '%$input%' LIMIT 50 ''');
    return data;
  }

  Future<List> getAllPatientsSearchedPhone(String input) async {
    List data = await dataHelper.readData(
        '''SELECT * FROM patients  WHERE phone_number LIKE '%$input%' LIMIT 50 ''');
    return data;
  }
}
