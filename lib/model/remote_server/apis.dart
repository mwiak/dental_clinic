import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/model/remote_server/server.dart';

SqlDb dataHelper = SqlDb();

Future<List> getAllPatientsAPI() async {
  List data = await dataHelper.readData(
      '''SELECT id, firstname,lastname,age ,phone_number FROM patients ORDER BY id DESC LIMIT 100 ''');
  return data;
}

Future<List> getAllPatientsSearchedAPI(String input) async {
  List data = await dataHelper.readData(
      '''SELECT  id, firstname,lastname,age ,phone_number FROM patients  WHERE firstname || ' ' || lastname LIKE '%$input%' LIMIT 10 ''');
  return data;
}

Future<List> getAllPatientsSearchedPhoneAPI(String input) async {
  List data = await dataHelper.readData(
      '''SELECT id, firstname,lastname,age ,phone_number FROM patients  WHERE phone_number LIKE '%$input%' LIMIT 10 ''');
  return data;
}

Future<int> saveNewPatientAPI(String firstName, String lastName, String age,
    String phone, String date) async {
  int data = await dataHelper.insertData(
      '''INSERT INTO patients (firstname,lastname,age,phone_number,date) VALUES ('$firstName','$lastName','$age','$phone', '$date') ''');
  return data;
}

Future<int> modifyPatientAPI(
    int id, String firstName, String lastName, String age, String phone) async {
  int data = await dataHelper.updateData(
      '''UPDATE patients  SET firstname = '$firstName',lastname = '$lastName',age = '$age',phone_number = '$phone' WHERE id = $id ''');
  return data;
}
