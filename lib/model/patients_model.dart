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
    List data = await dataHelper.readData('''SELECT * FROM patients''');
    return data;
  }
}
