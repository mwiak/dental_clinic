import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/shared/custom_widgets/patient_item.dart';
import 'package:dental_clinic/shared/custom_widgets/text_boxes.dart';
import 'package:dental_clinic/view/patient_menu_screens/patient_screen.dart';
import 'package:dental_clinic/view_model/patients_provider.dart';
import 'package:dental_clinic/view_model/user_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../model/reminder_entity.dart';
import '../../shared/custom_widgets/barboxes.dart';
import 'package:intl/intl.dart';

import '../../shared/public_methods/datetime_methods.dart';

class PatientsRecord extends StatefulWidget {
  const PatientsRecord({super.key});

  @override
  State<PatientsRecord> createState() => _PatientsRecordState();
}

class _PatientsRecordState extends State<PatientsRecord> {
  SqlDb dataHelper = SqlDb();
  TextEditingController searchC = TextEditingController();
  String searchMode = 'name';
  String numberOfPatientsMode = 'limit';
  String patientCardMode = 'compact';

  TextEditingController firstNameC = TextEditingController();
  TextEditingController lastNameC = TextEditingController();
  TextEditingController ageC = TextEditingController();
  TextEditingController phoneC = TextEditingController();

  String firstName = '';
  String lastName = '';
  String age = '';
  String phone = '';
  String date = '';

  final itemsController = FlyoutController();
  final itemsAttachKey = GlobalKey();
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  String currentDateToString(DateTime dateInput) {
    String format = 'dd/MM/yyyy';
    DateFormat dateFormatter = DateFormat(format);
    String dateString = dateFormatter.format(dateInput);
    return dateString;
  }

  String searchModeParse() {
    switch (searchMode) {
      case 'name':
        return AppLocalizations.of(context)!.name;
      case 'phone':
        return AppLocalizations.of(context)!.phone;
      default:
        return '';
    }
  }

  late PatientsProvider patientsProvider;

  String? firstNameError;
  String? lastNameError;
  String? ageError;
  String? phoneError;

  void validateFields() {
    if (firstNameC.text.isNotEmpty &&
        lastNameC.text.isNotEmpty &&
        ageC.text.isNotEmpty &&
        phoneC.text.isNotEmpty) {
      saveNewPatient();
    } else {
      showBar(context, AppLocalizations.of(context)!.title_required,
          InfoBarSeverity.warning);
    }
  }

  void trimAllControllers() {
    firstName = firstNameC.text.trim();
    lastName = lastNameC.text.trim();
    age = ageC.text.trim();
    phone = phoneC.text.trim();
  }

  void clearAllControllers() {
    firstNameC.clear();
    lastNameC.clear();
    ageC.clear();
    phoneC.clear();
  }

  //search
  Future<List> getPatientLogic(BuildContext context) async {
    if (searchC.text.isEmpty) {
      if (numberOfPatientsMode == 'limit') {
        return Provider.of<PatientsProvider>(context, listen: true)
            .getAllPatientsLimited();
      } else {
        return Provider.of<PatientsProvider>(context, listen: true)
            .getAllPatients();
      }
    } else if (searchMode == 'name') {
      return Provider.of<PatientsProvider>(context, listen: true)
          .getAllPatientsSearched(searchC.text.trim());
    } else {
      return Provider.of<PatientsProvider>(context, listen: true)
          .getAllPatientsSearchedPhone(searchC.text.trim());
    }
  }

  Future<void> saveNewPatient() async {
    trimAllControllers();
    date = currentDateToString(DateTime.now());
    int response = await patientsProvider.addNewPatient(
        firstName, lastName, age, phone, date);
    if (response > 0) {
      showBar(context, AppLocalizations.of(context)!.success,
          InfoBarSeverity.success);
      clearAllControllers();
      Navigator.of(context).push(FluentPageRoute(
          builder: (context) => PatientScreen(
              id: response, patientName: '$firstName $lastName')));
    } else {
      showBar(
          context, AppLocalizations.of(context)!.failed, InfoBarSeverity.error);
    }
  }

  //reminders logic
  Future<List> getAllReminders() async {
    List ongoingData = await dataHelper
        .readData('''SELECT * FROM notifications WHERE status = 'ongoing' ''');
    List dueData = await dataHelper
        .readData('''SELECT * FROM notifications WHERE status =  'due' ''');
    List ongoing = [];
    ongoing = ongoingData.map((reminder) {
      return ReminderEntity(
          id: reminder['id'],
          patientId: reminder['patient_id'],
          patientName: reminder['name'],
          title: reminder['title'] ?? '',
          date: stringToDateN(reminder['end_date']),
          status: reminder['status']);
    }).toList();
    List due = [];
    due = dueData.map((reminder) {
      return ReminderEntity(
          id: reminder['id'],
          patientId: reminder['patient_id'],
          patientName: reminder['name'],
          title: reminder['title'] ?? '',
          date: stringToDateN(reminder['end_date']),
          status: reminder['status']);
    }).toList();

    List filteredOngoing = ongoing
        .where((element) => element.date.difference(DateTime.now()).inHours < 0)
        .toList();
    for (ReminderEntity reminder in filteredOngoing) {
      int response = await dataHelper.updateData(
          ''' UPDATE notifications set status = 'due' WHERE id = ${reminder.id}''');
    }

    List data = filteredOngoing + due;

    List empty = [];
    return data;
  }

  void showRemindersAlert(BuildContext context) async {
    List data = await getAllReminders();
    if (data.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (context) => ContentDialog(
          title: Row(
            children: [
              Icon(FluentIcons.ringer),
              SizedBox(
                width: 10,
              ),
              Text(AppLocalizations.of(context)!.new_reminders_message),
            ],
          ),
          content: Text.rich(TextSpan(text: data.length.toString(), children: [
            TextSpan(text: '  '),
            TextSpan(
                text: AppLocalizations.of(context)!.reminders_number_message)
          ])),
          actions: [
            Button(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.pop(context);
                // Delete file here
              },
            ),
          ],
        ),
      );
    }
  }

  //

  void showContentDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(AppLocalizations.of(context)!.add_new_patient),
        content: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            InputText(
              controller: firstNameC,
              label: AppLocalizations.of(context)!.first_name,
              requiredSymbol: '*',
            ),
            SizedBox(
              height: 5,
            ),
            InputText(
              controller: lastNameC,
              label: AppLocalizations.of(context)!.last_name,
              requiredSymbol: '*',
            ),
            SizedBox(
              height: 5,
            ),
            InputText(
              controller: ageC,
              label: AppLocalizations.of(context)!.age,
              requiredSymbol: '*',
            ),
            SizedBox(
              height: 5,
            ),
            InputText(
              controller: phoneC,
              label: AppLocalizations.of(context)!.phone,
              requiredSymbol: '*',
            )
          ],
        ),
        actions: [
          Button(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
              // Delete file here
            },
          ),
          FilledButton(
            child: Text(AppLocalizations.of(context)!.add),
            onPressed: () {
              validateFields();
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
      patientsProvider = Provider.of<PatientsProvider>(context, listen: false);
      patientCardMode =
          Provider.of<UserProvider>(context, listen: false).displayMode;
      showRemindersAlert(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(50.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  // color: FluentTheme.of(context).micaBackgroundColor,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: IconButton(
                        icon: const Icon(FluentIcons.search),
                        onPressed: () {},
                      ),
                    ),
                    Expanded(
                      child: TextBox(
                        controller: searchC,
                        padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                        placeholder: AppLocalizations.of(context)!.search,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        onChanged: (input) {
                          setState(() {});
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Text(AppLocalizations.of(context)!.search_via),
                    ),
                    DropDownButton(
                      title: Text(searchModeParse()),
                      items: [
                        MenuFlyoutItem(
                            text: Tooltip(
                              message: AppLocalizations.of(context)!
                                  .status_hover_message,
                              displayHorizontally: true,
                              useMousePosition: false,
                              style: TooltipThemeData(preferBelow: true),
                              child: Text(AppLocalizations.of(context)!.name),
                            ),
                            onPressed: () {
                              setState(() {
                                searchMode = 'name';
                              });
                            }),
                        const MenuFlyoutSeparator(),
                        MenuFlyoutItem(
                            text: Text(AppLocalizations.of(context)!.phone),
                            onPressed: () {
                              setState(() {
                                searchMode = 'phone';
                              });
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            CommandBar(
              overflowBehavior: CommandBarOverflowBehavior.noWrap,
              primaryItems: [
                CommandBarBuilderItem(
                  builder: (context, mode, w) => Tooltip(
                    message: AppLocalizations.of(context)!.add_new_patient,
                    child: w,
                  ),
                  wrappedItem: CommandBarButton(
                    icon: const Icon(FluentIcons.add),
                    label: Text(AppLocalizations.of(context)!.add_new_patient),
                    onPressed: () {
                      showContentDialog(context);
                    },
                  ),
                ),
                CommandBarButton(
                  label: FlyoutTarget(
                      controller: itemsController,
                      child: Button(
                        child:
                            Text(AppLocalizations.of(context)!.display_options),
                        onPressed: () {
                          itemsController.showFlyout(
                            autoModeConfiguration: FlyoutAutoConfiguration(
                              preferredMode: FlyoutPlacementMode.bottomCenter,
                            ),
                            barrierDismissible: true,
                            dismissOnPointerMoveAway: false,
                            dismissWithEsc: true,
                            navigatorKey: rootNavigatorKey.currentState,
                            builder: (context) {
                              return StatefulBuilder(builder: (context, s) {
                                return MenuFlyout(items: [
                                  RadioMenuFlyoutItem(
                                    text: Text(
                                      AppLocalizations.of(context)!.limit_500,
                                    ),
                                    value: 'limit',
                                    groupValue: numberOfPatientsMode,
                                    onChanged: (v) {
                                      s(() => setState(() {
                                            numberOfPatientsMode = v;
                                          }));
                                    },
                                  ),
                                  RadioMenuFlyoutItem(
                                    text: Text(
                                      AppLocalizations.of(context)!.display_all,
                                    ),
                                    value: 'all',
                                    groupValue: numberOfPatientsMode,
                                    onChanged: (v) {
                                      s(() => setState(() {
                                            numberOfPatientsMode = v;
                                          }));
                                    },
                                  ),
                                  const MenuFlyoutSeparator(),
                                  RadioMenuFlyoutItem(
                                    text: Text(
                                      AppLocalizations.of(context)!
                                          .compact_card,
                                    ),
                                    value: 'compact',
                                    groupValue: patientCardMode,
                                    onChanged: (v) {
                                      s(() => setState(() {
                                            Provider.of<UserProvider>(context,
                                                    listen: false)
                                                .modifyDisplayMode(v);
                                            patientCardMode = v;
                                          }));
                                    },
                                  ),
                                  RadioMenuFlyoutItem(
                                    text: Text(
                                      AppLocalizations.of(context)!
                                          .detailed_card,
                                    ),
                                    value: 'detailed',
                                    groupValue: patientCardMode,
                                    onChanged: (v) {
                                      s(() => setState(() {
                                            Provider.of<UserProvider>(context,
                                                    listen: false)
                                                .modifyDisplayMode(v);
                                            patientCardMode = v;
                                          }));
                                    },
                                  ),
                                ]);
                              });
                            },
                          );
                        },
                      )),
                  onPressed: null,
                ),
              ],
            ),
            const Divider(
              style: DividerThemeData(thickness: 2),
            ),
            Expanded(
              child: FutureBuilder(
                  future: getPatientLogic(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: ProgressRing());
                    } else if (snapshot.hasError) {
                      print(snapshot.error.toString());
                      return Text(snapshot.error.toString());
                    } else {
                      if (patientCardMode == 'compact') {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 12,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 5),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, i) {
                                return PatientItem(
                                  patientData: snapshot.data![i],
                                );
                              }),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, i) {
                                return PatientDetailedItem(
                                  patientData: snapshot.data![i],
                                );
                              }),
                        );
                      }
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
