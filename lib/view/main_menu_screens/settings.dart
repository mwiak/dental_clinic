import 'package:dental_clinic/shared/strings/patient_screen.dart';
import 'package:dental_clinic/view/main_screen.dart';
import 'package:dental_clinic/view/patient_menu_screens/medical_record.dart';
import 'package:dental_clinic/view/patient_menu_screens/patient_reminders.dart';
import 'package:dental_clinic/view/patient_menu_screens/patients_info.dart';
import 'package:dental_clinic/view/patient_menu_screens/pregnancy.dart';
import 'package:dental_clinic/view/patient_menu_screens/sessions.dart';
import 'package:dental_clinic/view/settings_subpages/general_setting.dart';
import 'package:dental_clinic/view/settings_subpages/shortcuts.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Settings extends StatefulWidget {
  Settings({
    super.key,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int topIndex = 0;
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: bucket,
      child: NavigationView(
        pane: NavigationPane(
          displayMode: PaneDisplayMode.top,
          selected: topIndex,
          onChanged: (int i) => setState(() => topIndex = i),
          items: [
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text('إعدادات عامة'),
              body: GeneralSettings(),
            ),
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text('الاختصارات'),
              body: ShortcutsPage(),
            ),
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text('الأدوية'),
              body: GeneralSettings(),
            ),
            PaneItem(
              icon: const SizedBox.shrink(),
              title: Text('التشخيص'),
              body: GeneralSettings(),
            ),
          ],
        ),
      ),
    );
  }
}
