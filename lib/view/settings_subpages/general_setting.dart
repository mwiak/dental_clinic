import 'package:dental_clinic/model/api/syrian_pound_scrapper.dart';
import 'package:dental_clinic/view_model/backup_provider.dart';

import 'package:dental_clinic/shared/theme.dart';

import 'package:dental_clinic/view_model/user_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/custom_widgets/text_boxes.dart';
import '../../view_model/navigationService.dart';

//screen for setting user preferences
class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
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
    centerC.clear();
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
    NavigationService.setOverlayContext(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10,
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
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                                  textDirection: TextDirection.ltr,
                                  '+963959459372')
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Card(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 400,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('مجلد النسخ الاحتياطي'),
                            SizedBox(
                              width: 10,
                            ),
                            Card(
                              backgroundColor: Color(0xFFB2FF59),
                              child: Text(context
                                  .watch<BackupProvider>()
                                  .activeDirectory),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Button(
                                child: Text('تغير المجلد'),
                                onPressed: () {
                                  Provider.of<BackupProvider>(context,
                                          listen: false)
                                      .pickDirectory();
                                })
                          ],
                        ),
                        SizedBox(
                          height: 1,
                        ),
                        Divider(),
                        SizedBox(
                          height: 1,
                        ),
                        SizedBox(
                          width: 300,
                          child: Row(
                            textDirection: TextDirection.ltr,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Button(
                                  child: Text('إنشاء نسخة الآن'),
                                  onPressed: () {
                                    Provider.of<BackupProvider>(context,
                                            listen: false)
                                        .newBackup();
                                  })
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
