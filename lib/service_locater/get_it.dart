import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/view_model/app_provider.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton(() => SqlDb());
}
