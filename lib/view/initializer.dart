import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/view/Register.dart';
import 'package:dental_clinic/view/activation_page.dart';
import 'package:dental_clinic/view_model/activation_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../model/encryption/windows_encryption.dart';
import '../view_model/navigationService.dart';
import '../view_model/user_provider.dart';
import 'main_screen.dart';

class Initializer extends StatefulWidget {
  const Initializer({super.key});

  @override
  State<Initializer> createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> {
  SqlDb dataHelper = SqlDb();

  Future<void> checkForUser(context) async {
    List data =
        await dataHelper.readData('''SELECT * FROM user WHERE id = 1''');
    await Future.delayed(Duration(seconds: 1));
    if (data.isEmpty) {
      Navigator.of(context).pushReplacement(
        FluentPageRoute(
          builder: (context) => const Register(),
        ),
      );
    } else {
      Provider.of<UserProvider>(context, listen: false).getUserData();

      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pushReplacement(
        FluentPageRoute(
          builder: (context) => MainScreen(
            preEntry: 'Denta',
          ),
        ),
      );
    }
  }

  Future<void> checkForActToken(BuildContext context) async {
    String? token;
    if (Platform.isWindows) {
      token = await WindowsSecureStorage.readToken();
    } else if (Platform.isMacOS) {
      final secureStorage = FlutterSecureStorage();
      token = await secureStorage.read(key: 'd1t1_auth');
    }
    if (token != null) {
      bool isTokenValid = token.endsWith('0x12');
      if (isTokenValid) {
        String result = token.substring(0, token.length - 4);
        await Provider.of<ActivationProvider>(context, listen: false)
            .loginOptional(context, result);
        checkForUser(context);
      } else {
        Navigator.of(context).pushReplacement(
          FluentPageRoute(
            builder: (context) => const ActivationPage(),
          ),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        FluentPageRoute(
          builder: (context) => const ActivationPage(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkForActToken(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProgressBar(),
        ],
      ),
    );
  }
}
