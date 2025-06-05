import 'dart:io';

import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/model/remote_server/server.dart';
import 'package:dental_clinic/service_locater/get_it.dart';
import 'package:dental_clinic/view/Register.dart';
import 'package:dental_clinic/view/initializer.dart';
import 'package:dental_clinic/view_model/activation_provider.dart';
import 'package:dental_clinic/view_model/custome_field_provider.dart';
import 'package:dental_clinic/view_model/exchange_rate_provider.dart';
import 'package:dental_clinic/view_model/navigationService.dart';
import 'package:dental_clinic/view_model/patients_provider.dart';
import 'package:dental_clinic/view_model/reminders_provider.dart';
import 'package:dental_clinic/view_model/remote_users_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dental_clinic/view_model/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

//start point of the application
void main() async {
  setup();
  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(//defining multi providers and set them as the root
      MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => PatientsProvider()),
    ChangeNotifierProvider(create: (_) => CustomFieldProvider()),
    ChangeNotifierProvider(create: (_) => RemindersProvider()),
    ChangeNotifierProvider(create: (_) => ExchangeRateProvider()),
    ChangeNotifierProvider(create: (_) => RemoteUsersProvider()),
    ChangeNotifierProvider(create: (_) => ActivationProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //  this widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      navigatorKey: NavigationService.navigatorKey,
      theme: Provider.of<UserProvider>(context).themeMode, // Light theme
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Provider.of<UserProvider>(context).language,
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Spanish
      ],
      home: Initializer(),
    );
  }
}
