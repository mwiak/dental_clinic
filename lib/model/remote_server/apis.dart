import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/model/remote_server/server.dart';

SqlDb dataHelper = SqlDb();

Future<List> getAllPatientsAPI() async {
  List data = await dataHelper.readData(
      '''SELECT id, firstname,lastname,age ,phone_number FROM patients ORDER BY id DESC LIMIT 500 ''');
  return data;
}

Future<List> getAllPatientsSearchedAPI(String input) async {
  List data = await dataHelper.readData(
      '''SELECT  id, firstname,lastname,age ,phone_number FROM patients  WHERE firstname || ' ' || lastname LIKE '%$input%' LIMIT 50 ''');
  return data;
}

Future<List> getAllPatientsSearchedPhoneAPI(String input) async {
  List data = await dataHelper.readData(
      '''SELECT id, firstname,lastname,age ,phone_number FROM patients  WHERE phone_number LIKE '%$input%' LIMIT 50 ''');
  return data;
}

Future<int> saveNewPatientAPI(String firstName, String lastName, String age,
    String phone, String date) async {
  int data = await dataHelper.insertData(
      '''INSERT INTO patients (firstname,lastname,age,phone_number,date) VALUES ('$firstName','$lastName','$age','$phone', '$date') ''');
  return data;
}
