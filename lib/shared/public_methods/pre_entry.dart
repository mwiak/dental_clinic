import 'package:dental_clinic/database/sqflite.dart';

SqlDb dataHelper = SqlDb();

bool getPreEntry(String value) {
  if (value == 'ZkI2314PoiuANmaPiaka742!sajksoowha') {
    return false;
  } else {
    return true;
  }
}

Future<bool> checkForS(String value) async {
  if (value == 'ZkI2314PoiuANmaPiaka742!sajksoowha') {
    List data =
        await dataHelper.readData('''SELECT COUNT(*) as total FROM patients''');
    int rowCount = data[0]['total'];
    if (rowCount >= 50) {
      return false;
    } else {
      return true;
    }
  } else {
    return true;
  }
}
