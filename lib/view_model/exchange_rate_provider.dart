import 'package:dental_clinic/database/sqflite.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ExchangeRateProvider extends ChangeNotifier {
  SqlDb dataHelper = SqlDb();

  double rate = 34.10;

  double spRate = 10900.00;

  Future<int> setRate(double value) async {
    rate = value;
    int response = await dataHelper
        .insertData(''' UPDATE prices SET exchange = $value WHERE id = 1''');
    return response;
  }

  Future<void> getRate() async {
    List data = await dataHelper.readData(''' SELECT * from prices''');
    rate = data[0]['exchange'];
  }

  Future<int> setSpRate(double value) async {
    spRate = value;
    int response = await dataHelper.insertData(
        ''' UPDATE prices SET syrian_pound_exchange = $value WHERE id = 1''');
    return response;
  }

  Future<void> getSpRate() async {
    List data = await dataHelper.readData(''' SELECT * from prices''');
    spRate = data[0]['syrian_pound_exchange'];
  }
}
