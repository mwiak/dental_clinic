import 'package:dental_clinic/view/main_menu_screens/patients_record.dart';
import 'package:dental_clinic/view/main_menu_screens/payments.dart';
import 'package:dental_clinic/view/main_menu_screens/reminders.dart';
import 'package:dental_clinic/view/main_menu_screens/remote_users_page.dart';
import 'package:dental_clinic/view/main_menu_screens/settings.dart';
import 'package:dental_clinic/view/main_menu_screens/waiting_list_page.dart';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//main screen is a wrapper widget with 4 routes: patients record, payments, reminders, and settings
class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int topIndex = 0;
  var displayMode = PaneDisplayMode.compact;

  void showDemoBanner(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
              constraints: BoxConstraints(
                  minWidth: 300, minHeight: 400, maxWidth: 300, maxHeight: 500),
              content: Column(
                children: [
                  Text(''' مرحبًا بك في تطبيق Denta!
يسرّنا انضمامك إلى نسختنا التجريبية، حيث يمكنك الاستفادة من جميع ميزات النسخة الكاملة.                    
ابدأ اليوم بإدارة ملفات مرضاك بسهولة وفعالية — مع العلم أن النسخة التجريبية تتيح لك تسجيل حتى 25 مريضًا.                         
نتمنى لك تجربة مميزة، وندعوك لاستكشاف كل ما يقدمه التطبيق لتسهيل عملك اليومي!                            ''')
                ],
              ),
              actions: [
                Button(
                    child: Text('إغلاق'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
          size: NavigationPaneSize(openWidth: 150),
          displayMode: displayMode,
          selected: topIndex,
          onChanged: (int i) => setState(() => topIndex = i),
          onItemPressed: (index) {
            // Do anything you want to do, such as:
            if (index == topIndex) {
              if (displayMode == PaneDisplayMode.open) {
                setState(() => displayMode = PaneDisplayMode.compact);
              } else if (displayMode == PaneDisplayMode.compact) {
                setState(() => displayMode = PaneDisplayMode.open);
              }
            }
          },
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.people),
              title: Text(AppLocalizations.of(context)!.patients_record),
              body: PatientsRecord(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.list),
              title: Text('قائمة الانتظار'),
              body: WaitingListPage(),
            ),
            PaneItemSeparator(thickness: 1),
            PaneItem(
              icon: const Icon(FluentIcons.circle_dollar),
              title: Text(AppLocalizations.of(context)!.payments),
              body: Payments(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.ringer),
              title: Text(AppLocalizations.of(context)!.notifications),
              body: NavigationView(
                content: Reminders(),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.remote_application),
              title: Text('remote users'),
              body: NavigationView(
                content: RemoteUsersPage(),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: Text(AppLocalizations.of(context)!.setting),
              body: NavigationView(
                content: Settings(),
              ),
            ),
          ]),
    );
  }
}
