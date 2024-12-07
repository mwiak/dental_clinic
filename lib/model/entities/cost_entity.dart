import 'package:dental_clinic/shared/public_methods/datetime_methods.dart';

class CostEntity {
  late int id;
  late String type;
  late num amount;
  late DateTime date;

  CostEntity.fromTreatmentMap(Map<String, dynamic> map) {
    id = map['id'] ?? 0; // Default to 0 if 'id' is null
    type =
        map['treatment'] ?? ''; // Default to an empty string if 'type' is null
    amount = map['cost'] ?? 0; // Default to 0 if 'amount' is null
    date = map['date'] != null
        ? stringToDateN(map['date'])
        : DateTime.now(); // Parse date or default to now
  }

  CostEntity.fromImplantMap(Map<String, dynamic> map) {
    id = map['id'] ?? 0; // Default to 0 if 'id' is null
    type = map['type'] ?? ''; // Default to an empty string if 'type' is null
    amount = map['cost'] ?? 0; // Default to 0 if 'amount' is null
    date = map['date'] != null
        ? stringToDateN(map['date'])
        : DateTime.now(); // Parse date or default to now
  }

  CostEntity.fromGeneralTreatmentMap(Map<String, dynamic> map) {
    id = map['id'] ?? 0; // Default to 0 if 'id' is null
    type = map['treatment_type'] ??
        ''; // Default to an empty string if 'type' is null
    amount = map['cost'] ?? 0; // Default to 0 if 'amount' is null
    date = map['date'] != null
        ? stringToDateN(map['date'])
        : DateTime.now(); // Parse date or default to now
  }
}
