import 'package:dental_clinic/shared/custom_widgets/waiting_list_patient_item.dart';
import 'package:dental_clinic/view_model/remote_users_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../patient_menu_screens/patient_screen.dart';

class WaitingListPage extends StatefulWidget {
  const WaitingListPage({super.key});

  @override
  State<WaitingListPage> createState() => _WaitingListPageState();
}

class _WaitingListPageState extends State<WaitingListPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'قائمة الانتظار',
            style: FluentTheme.of(context).typography.title,
          ),
          SizedBox(
            height: 20,
          ),
          Divider(),
          SizedBox(),
          Consumer<RemoteUsersProvider>(builder: (context, value, child) {
            return SizedBox(
                width: 500,
                height: 600,
                child: value.waitingList.isNotEmpty
                    ? ListView.builder(
                        itemCount: value.waitingList.length,
                        itemBuilder: (context, i) {
                          return WaitingListPatientItem(
                            data: value.waitingList[i],
                            onRemove: () {
                              Provider.of<RemoteUsersProvider>(context,
                                      listen: false)
                                  .removePatientFromWaitingList(
                                      value.waitingList[i].id);
                            },
                            onOpen: () {
                              Navigator.of(context)
                                  .pushReplacement(FluentPageRoute(
                                      builder: (context) => PatientScreen(
                                            id: value.waitingList[i].id,
                                            patientName: value
                                                    .waitingList[i].firstname +
                                                ' ' +
                                                value.waitingList[i].lastname,
                                            prePageIndex: 1,
                                            index: 1,
                                          )));
                            },
                          );
                        })
                    : Center(
                        child: Text(
                            'قائمة الانتظار فارغة\n يمكن للمستخدمين عن بعد إضافة المرضى في قاعة الانتظار لهذه القائمة'),
                      ));
          })
        ],
      ),
    );
  }
}
