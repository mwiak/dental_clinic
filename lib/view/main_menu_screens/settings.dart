import 'package:dental_clinic/shared/theme.dart';
import 'package:dental_clinic/view/main_menu_screens/general_treatments_customization.dart';
import 'package:dental_clinic/view/main_menu_screens/implants_customization.dart';
import 'package:dental_clinic/view/main_menu_screens/treatments_customization.dart';
import 'package:dental_clinic/view_model/user_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//screen for setting user preferences
class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String selectedLanguage = 'English';
  String mode = 'light';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      selectedLanguage =
          Provider.of<UserProvider>(context, listen: false).language ==
                  Locale('en')
              ? 'English'
              : 'Arabic';
      mode = Provider.of<UserProvider>(context, listen: false).themeMode ==
              darkMode
          ? 'dark'
          : 'light';
    });
  }

  @override
  Widget build(BuildContext context) {
    selectedLanguage =
        Provider.of<UserProvider>(context, listen: true).language ==
                Locale('en')
            ? 'English'
            : 'Arabic';
    mode =
        Provider.of<UserProvider>(context, listen: true).themeMode == darkMode
            ? 'dark'
            : 'light';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(AppLocalizations.of(context)!.type_customization),
                  Divider(),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FilledButton(
                          child: const Text('customize treatments types'),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                FluentPageRoute(
                                    builder: (context) =>
                                        TreatmentsCustomization()));
                          }),
                      FilledButton(
                          child: const Text('customize implants types'),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                FluentPageRoute(
                                    builder: (context) =>
                                        ImplantsCustomization()));
                          }),
                      FilledButton(
                          child:
                              const Text('customize general treatments types'),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                FluentPageRoute(
                                    builder: (context) =>
                                        GeneralTreatmentsCustomization()));
                          })
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Card(
              child: SizedBox(
                width: 360,
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.preferences),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 300,
                      child: Row(
                        children: [
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
                                  .modifyLanguage(val!);
                              setState(
                                  () => selectedLanguage = val ?? 'English');
                            },
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          ComboBox<String>(
                            value: mode,
                            items: [
                              ComboBoxItem(
                                value: 'light',
                                child:
                                    Text(AppLocalizations.of(context)!.light),
                              ),
                              ComboBoxItem(
                                value: 'dark',
                                child: Text(AppLocalizations.of(context)!.dark),
                              )
                            ],
                            onChanged: (val) {
                              Provider.of<UserProvider>(context, listen: false)
                                  .modifyDark(val!);
                              setState(() => mode = val ?? 'light');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
