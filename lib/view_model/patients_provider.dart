import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/model/patients_model.dart';
import 'package:dental_clinic/shared/public_methods/pre_entry.dart';
import 'package:fluent_ui/fluent_ui.dart';

class PatientsProvider extends ChangeNotifier {
  PatientsModel patientsModel = PatientsModel();
  SqlDb dataHelper = SqlDb();

  Future<int> addNewPatient(
      String firstName,
      String lastName,
      String normalizedName,
      String age,
      String phone,
      String address,
      String date) async {
    int response = await patientsModel.addNewPatient(
        firstName, lastName, normalizedName, age, phone, address, date);
    return response;
  }

  Future<List> getAllPatients() async {
    List data = await patientsModel.getAllPatients();
    return data;
  }

  Future<List> getAllPatientsLimited() async {
    List data = await patientsModel.getAllPatientsLimited();
    return data;
  }

  Future<List> getAllPatientsSearched(String input) async {
    List data = await patientsModel.getAllPatientsSearched(input);
    return data;
  }

  Future<List> getAllPatientsSearchedPhone(String input) async {
    List data = await patientsModel.getAllPatientsSearchedPhone(input);
    return data;
  }
}
