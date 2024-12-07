import 'package:dental_clinic/database/sqflite.dart';

//modifying or deleting existing patient
class PatientMenuModel {
  SqlDb dataHelper = SqlDb();

  Future<List> getPatientInfo(int id) async {
    List data =
        await dataHelper.readData('''SELECT * FROM patients WHERE id = $id ''');
    return data;
  }

  Future<int> modifyPatientInfo(
      int id,
      String firstName,
      String lastName,
      String age,
      String phone,
      String medical,
      String surgery,
      String notes) async {
    int response = await dataHelper.updateData('''UPDATE patients SET
         firstname = '$firstName',
         lastname = '$lastName',
         age = '$age',
         phone_number = '$phone',
         medical = '$medical',
         surgery = '$surgery',
         notes = '$notes'   
         WHERE id = $id ''');
    return response;
  }

  Future<int> deletePatient(int id) async {
    int response = await dataHelper
        .deleteData('''DELETE  FROM patients WHERE id = $id ''');

    return response;
  }
}
