import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/custom_widgets/saved_user.dart';
import 'package:dental_clinic/shared/custom_widgets/text_boxes.dart';
import 'package:dental_clinic/view_model/remote_users_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

//screen for displaying reminders when specified time is due
class RemoteUsersPage extends StatefulWidget {
  const RemoteUsersPage({super.key});

  @override
  State<RemoteUsersPage> createState() => _RemoteUsersPageState();
}

class _RemoteUsersPageState extends State<RemoteUsersPage> {
  SqlDb dataHelper = SqlDb();
  bool isBroad = false;

  @override
  void initState() {
    super.initState();
  }

  void showModifyUserNameDialog(
      BuildContext context, String name, int id) async {
    TextEditingController nameC = TextEditingController(text: name);
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text('تعديل اسم مستخدم الجهاز'),
        content: Column(
          children: [
            InfoEntrySmall(
                controller: nameC, label: 'اسم مستخدم الجهاز', readOnly: true),
          ],
        ),
        actions: [
          OutlinedButton(
              child: Text('تعديل'),
              onPressed: () {
                if (nameC.text.isNotEmpty) {
                  Provider.of<RemoteUsersProvider>(context, listen: false)
                      .modifyRemoteUserName(nameC.text.trim(), id);
                  Navigator.of(context).pop();
                } else {
                  showBar(context, 'ادخل اسم جديد', InfoBarSeverity.warning);
                }
              }),
          Button(
              child: Text('رجوع'),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Button(
              child: Text('إضافة جهاز جديد'),
              onPressed: () {
                Provider.of<RemoteUsersProvider>(context, listen: false)
                    .startNewServerLogic(context);
              }),
          const SizedBox(
            height: 20,
          ),
          ToggleButton(
              child: Text('قبول اتصال الأجهزة المحفوظة'),
              checked: context.watch<RemoteUsersProvider>().isServing,
              onChanged: (val) {
                final provider = context.read<RemoteUsersProvider>();
                provider.toggleServing(val);

                if (val) {
                  provider.startServerLogic();
                } else {
                  provider.stopServer();
                }
              }),
          // ToggleButton(
          //     child: Text('start king salman broadcast'),
          //     checked: context.watch<RemoteUsersProvider>().isServing,
          //     onChanged: (val) {
          //       final provider = context.read<RemoteUsersProvider>();
          //       provider.toggleServing(val);
          //
          //       if (val) {
          //         // provider.startDiscoveryService();
          //       } else {
          //         provider.stopBroadcast();
          //       }
          //     }),
          const SizedBox(
            height: 20,
          ),
          Text(
            'الأجهزة القابلة للاتصال',
            style: FluentTheme.of(context).typography.title,
          ),
          const SizedBox(
            height: 5,
          ),
          Divider(),
          const SizedBox(
            height: 20,
          ),
          Consumer<RemoteUsersProvider>(builder: (context, value, child) {
            return Expanded(
              child: ListView.builder(
                  itemCount: value.devices.length,
                  itemBuilder: (context, i) {
                    return SavedUser(
                      id: value.devices[i]['id'],
                      name: value.devices[i]['name'],
                      device: value.devices[i]['device'],
                      isConnected: value.devices[i]['flag'],
                      onChangeName: () {
                        showModifyUserNameDialog(context,
                            value.devices[i]['name'], value.devices[i]['id']);
                      },
                      onDelete: () {
                        Provider.of<RemoteUsersProvider>(context, listen: false)
                            .deleteUser(value.devices[i]['id']);
                      },
                    );
                  }),
            );
          })
        ],
      ),
    );
  }
}
