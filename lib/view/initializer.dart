import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/view/Register.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

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
    if (data.isEmpty) {
      Navigator.of(context).pushReplacement(
        FluentPageRoute(
          builder: (context) => const Register(),
        ),
      );
    } else {
      Provider.of<UserProvider>(context, listen: false).getUserData();
      Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pushReplacement(
        FluentPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkForUser(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Center(child: ProgressBar()),
    );
  }
}
