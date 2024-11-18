import 'package:dental_clinic/shared/custom_widgets/patient_item.dart';
import 'package:dental_clinic/shared/custom_widgets/text_boxes.dart';
import 'package:dental_clinic/view_model/patients_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../shared/custom_widgets/barboxes.dart';
import 'package:intl/intl.dart';

class PatientsRecord extends StatefulWidget {
  const PatientsRecord({super.key});

  @override
  State<PatientsRecord> createState() => _PatientsRecordState();
}

class _PatientsRecordState extends State<PatientsRecord> {
  TextEditingController firstNameC = TextEditingController();
  TextEditingController lastNameC = TextEditingController();
  TextEditingController ageC = TextEditingController();
  TextEditingController phoneC = TextEditingController();

  String firstName = '';
  String lastName = '';
  String age = '';
  String phone = '';
  String date = '';

  String currentDateToString(DateTime dateInput) {
    String format = 'dd/MM/YYYY';
    DateFormat dateFormatter = DateFormat(format);
    String dateString = dateFormatter.format(dateInput);
    return dateString;
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

  Future<void> saveNewPatient() async {
    trimAllControllers();
    date = currentDateToString(DateTime.now());
    int response = await patientsProvider.addNewPatient(
        firstName, lastName, age, phone, date);
    if (response > 0) {
      showBar(context, AppLocalizations.of(context)!.success,
          InfoBarSeverity.success);
      clearAllControllers();
      Navigator.pop(context);
    } else {
      showBar(
          context, AppLocalizations.of(context)!.failed, InfoBarSeverity.error);
    }
  }

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
                label: AppLocalizations.of(context)!.first_name),
            SizedBox(
              height: 5,
            ),
            InputText(
                controller: lastNameC,
                label: AppLocalizations.of(context)!.last_name),
            SizedBox(
              height: 5,
            ),
            InputText(
                controller: ageC, label: AppLocalizations.of(context)!.age),
            SizedBox(
              height: 5,
            ),
            InputText(
                controller: phoneC, label: AppLocalizations.of(context)!.phone)
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
                  color: FluentTheme.of(context).micaBackgroundColor,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: IconButton(
                        icon: const Icon(FluentIcons.add, size: 24.0),
                        onPressed: () {
                          showContentDialog(context);
                        },
                      ),
                    ),
                    Expanded(
                      child: TextBox(
                        padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                        placeholder: AppLocalizations.of(context)!.search,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              style: DividerThemeData(thickness: 2),
            ),
            Expanded(
              child: FutureBuilder(
                  future: Provider.of<PatientsProvider>(context, listen: true)
                      .getAllPatients(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: ProgressRing());
                    } else if (snapshot.hasError) {
                      return Text('error');
                    } else {
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
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
