import 'package:dental_clinic/model/api/syrian_pound_scrapper.dart';
import 'package:dental_clinic/shared/custom_widgets/exchange_rate_panel.dart';
import 'package:dental_clinic/shared/theme.dart';
import 'package:dental_clinic/view/main_menu_screens/general_treatments_customization.dart';
import 'package:dental_clinic/view/main_menu_screens/implants_customization.dart';
import 'package:dental_clinic/view/main_menu_screens/treatments_customization.dart';
import 'package:dental_clinic/view_model/user_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/custom_widgets/text_boxes.dart';

//screen for setting user preferences
class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String selectedLanguage = 'English';
  String mode = 'light';

  void showModifyCenterDialog(BuildContext context) async {
    TextEditingController centerC = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        constraints: BoxConstraints(maxWidth: 300, maxHeight: 250),
        title: Text('تعديل اسم المركز'),
        content: Column(
          children: [
            InputText(
              controller: centerC,
              label: 'اسم المركز',
              requiredSymbol: '*',
            ),
          ],
        ),
        actions: [
          Button(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () {
              Navigator.pop(context);
              // Delete file here
            },
          ),
          FilledButton(
            child: Text(AppLocalizations.of(context)!.generic_modify),
            onPressed: () {
              if (centerC.text.isNotEmpty) {
                Provider.of<UserProvider>(context, listen: false)
                    .modifyCenter(centerC.text.trim());
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
    setState(() {});
  }

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
                          child: Text(AppLocalizations.of(context)!
                              .customize_treatments_types),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                FluentPageRoute(
                                    builder: (context) =>
                                        TreatmentsCustomization()));
                          }),
                      FilledButton(
                          child: Text(AppLocalizations.of(context)!
                              .customize_implants_types),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                FluentPageRoute(
                                    builder: (context) =>
                                        ImplantsCustomization()));
                          }),
                      FilledButton(
                          child: Text(AppLocalizations.of(context)!
                              .customize_general_treatments_types),
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
                width: 700,
                child: Column(
                  children: [
                    Text('سعر صرف دولار/ليرة تركية'),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    ExchangeRatePanel(),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Card(
              child: SizedBox(
                width: 700,
                child: Column(
                  children: [
                    Text('سعر صرف دولار/ليرة سورية'),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    ExchangeRateSyrianPanel(),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .modifyLanguage(val!);
                                  setState(() =>
                                      selectedLanguage = val ?? 'English');
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
                                    child: Text(
                                        AppLocalizations.of(context)!.light),
                                  ),
                                  ComboBoxItem(
                                    value: 'dark',
                                    child: Text(
                                        AppLocalizations.of(context)!.dark),
                                  )
                                ],
                                onChanged: (val) {
                                  Provider.of<UserProvider>(context,
                                          listen: false)
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
                ),
                SizedBox(
                  width: 10,
                ),
                Card(
                  child: SizedBox(
                    width: 250,
                    child: Row(
                      children: [
                        Text('اسم المركز:'),
                        SizedBox(
                          width: 6,
                        ),
                        Text(context.watch<UserProvider>().center),
                        Spacer(),
                        Button(
                            child: Text('تعديل'),
                            onPressed: () {
                              showModifyCenterDialog(context);
                            })
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              child: SizedBox(
                width: 360,
                child: Column(
                  children: [
                    Text('خدمة العملاء'),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 300,
                      child: Row(
                        textDirection: TextDirection.ltr,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                              width: 40, height: 40, 'assets/whatsup.png'),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                              textDirection: TextDirection.ltr, '+963959459372')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
