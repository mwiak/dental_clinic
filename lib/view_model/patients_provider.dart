import 'package:dental_clinic/model/patients_model.dart';
import 'package:fluent_ui/fluent_ui.dart';

class PatientsProvider extends ChangeNotifier {
  PatientsModel patientsModel = PatientsModel();

  Future<int> addNewPatient(String firstName, String lastName, String age,
      String phone, String date) async {
    int response = await patientsModel.addNewPatient(
        firstName, lastName, age, phone, date);
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
