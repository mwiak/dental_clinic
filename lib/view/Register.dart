import 'package:dental_clinic/shared/theme.dart';
import 'package:dental_clinic/view/initializer.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../view_model/user_provider.dart';
import 'main_screen.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String selectedLanguage = 'English';
  String mode = 'light';
  TextEditingController nameC = TextEditingController();
  TextEditingController centerC = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameC.dispose();
    centerC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Center(
        child: Container(
          height: 300,
          width: 300,
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.hello), //
              SizedBox(
                height: 5,
              ),
              TextBox(
                controller: nameC,
                placeholder: AppLocalizations.of(context)!.name,
              ),
              SizedBox(
                height: 5,
              ),
              TextBox(
                controller: centerC,
                placeholder: AppLocalizations.of(context)!.center,
              ),
              SizedBox(
                height: 5,
              ),
              ComboBox<String>(
                  value: selectedLanguage,
                  items: const [
                    ComboBoxItem(
                      value: 'English',
                      child: Text('English'),
                    ),
                    ComboBoxItem(
                      value: 'Arabic',
                      child: Text('العربية'),
                    )
                  ],
                  onChanged: (val) {
                    Provider.of<UserProvider>(context, listen: false)
                        .toggleLanguage(val ?? 'English');
                    setState(() => selectedLanguage = val ?? 'English');
                  }),
              SizedBox(
                height: 5,
              ),
              ComboBox<String>(
                  value: mode,
                  items: [
                    ComboBoxItem(
                      value: 'light',
                      child: Text(AppLocalizations.of(context)!.light),
                    ),
                    ComboBoxItem(
                      value: 'dark',
                      child: Text(AppLocalizations.of(context)!.dark),
                    )
                  ],
                  onChanged: (val) {
                    Provider.of<UserProvider>(context, listen: false)
                        .toggleDark(val ?? 'light');
                    setState(() => mode = val ?? 'light');
                  }),
              SizedBox(
                height: 5,
              ),
              Button(
                  child: Text(AppLocalizations.of(context)!.continue_c),
                  onPressed: () async {
                    await Provider.of<UserProvider>(context, listen: false)
                        .createNewUser(nameC.text, centerC.text,
                            selectedLanguage, mode == 'dark' ? true : false);
                    Navigator.of(context).pushReplacement(
                      FluentPageRoute(
                        builder: (context) => const Initializer(),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
