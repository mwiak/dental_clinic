import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/custom_widgets/flyout.dart';
import 'package:dental_clinic/shared/custom_widgets/text_boxes.dart';
import 'package:dental_clinic/view/main_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/patient_menu_model.dart';

class PatientsInfo extends StatefulWidget {
  final int patientId;

  const PatientsInfo({super.key, required this.patientId});

  @override
  State<PatientsInfo> createState() => _PatientsInfoState();
}

class _PatientsInfoState extends State<PatientsInfo>
    with AutomaticKeepAliveClientMixin {
  final FlyoutController saveController = FlyoutController();
  final FlyoutController deleteController = FlyoutController();
  final GlobalKey<NavigatorState> rootSaveNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> rootDeleteNavigatorKey =
      GlobalKey<NavigatorState>();

  PatientMenuModel patientMenuModel = PatientMenuModel();
  bool enabled = false;
  TextEditingController firstnameC = TextEditingController();
  TextEditingController lastnameC = TextEditingController();
  TextEditingController ageC = TextEditingController();
  TextEditingController phoneC = TextEditingController();
  TextEditingController medicalC = TextEditingController();
  TextEditingController surgeryC = TextEditingController();
  TextEditingController notesC = TextEditingController();

  String firstname = '';
  String lastname = '';
  String age = '';
  String phone = '';
  String medical = '';
  String surgery = '';
  String notes = '';

  String date = '';

  Future<void> getPatientInfo() async {
    List data = await patientMenuModel.getPatientInfo(widget.patientId);
    firstnameC.text = data[0]['firstname'] ?? '';
    lastnameC.text = data[0]['lastname'] ?? '';
    ageC.text = data[0]['age'] ?? '';
    phoneC.text = data[0]['phone_number'] ?? '';
    medicalC.text = data[0]['medical'] ?? '';
    surgeryC.text = data[0]['surgery'] ?? '';
    notesC.text = data[0]['notes'] ?? '';
    date = data[0]['date'] ?? '';

    setState(() {});
  }

  void validateModification() async {
    if (firstnameC.text.isNotEmpty &&
        lastnameC.text.isNotEmpty &&
        ageC.text.isNotEmpty &&
        phoneC.text.isNotEmpty) {
      firstname = firstnameC.text.trim();
      lastname = lastnameC.text.trim();
      age = ageC.text.trim();
      phone = phoneC.text.trim();
      medical = medicalC.text.trim();
      surgery = surgeryC.text.trim();
      notes = notesC.text.trim();

      int repsonse = await modifyPatientInfo();

      if (repsonse > 0) {
        showBar(context, AppLocalizations.of(context)!.message_saved,
            InfoBarSeverity.success);
        setState(() {
          enabled = false;
        });
      } else {
        showBar(context, AppLocalizations.of(context)!.message_failed,
            InfoBarSeverity.error);
      }
    } else {
      showBar(context, AppLocalizations.of(context)!.message_userBasic,
          InfoBarSeverity.warning);
    }
  }

  Future<int> modifyPatientInfo() async {
    int response = await patientMenuModel.modifyPatientInfo(widget.patientId,
        firstname, lastname, age, phone, medical, surgery, notes);
    return response;
  }

  Future<void> deletePatient() async {
    int response = await patientMenuModel.deletePatient(widget.patientId);
    if (response > 0) {
      Navigator.pushReplacement(
          context, FluentPageRoute(builder: (context) => MainScreen()));
    } else {
      showBar(context, AppLocalizations.of(context)!.message_generic_fail,
          InfoBarSeverity.error);
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getPatientInfo();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    InfoEntrySmall(
                      controller: firstnameC,
                      label: AppLocalizations.of(context)!.first_name,
                      readOnly: enabled,
                    ),
                    InfoEntrySmall(
                      controller: lastnameC,
                      label: AppLocalizations.of(context)!.last_name,
                      readOnly: enabled,
                    ),
                    InfoEntrySmall(
                      controller: ageC,
                      label: AppLocalizations.of(context)!.age,
                      readOnly: enabled,
                    ),
                    InfoEntrySmall(
                      controller: phoneC,
                      label: AppLocalizations.of(context)!.phone,
                      readOnly: enabled,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InfoLabel(
                      label: AppLocalizations.of(context)!.registration_date,
                      child: Row(
                        children: [
                          Text(date),
                        ],
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        SizedBox(
                            width: 100,
                            child: Button(
                                child: Text(enabled
                                    ? AppLocalizations.of(context)!.discard
                                    : AppLocalizations.of(context)!.edit),
                                onPressed: () {
                                  if (enabled) {
                                    getPatientInfo();
                                    setState(() {
                                      enabled = !enabled;
                                    });
                                  } else {
                                    setState(() {
                                      enabled = !enabled;
                                    });
                                  }
                                })),
                        SizedBox(
                          width: 7,
                        ),
                        enabled
                            ? FilledButton(
                                child: Text(AppLocalizations.of(context)!.save),
                                onPressed: () {
                                  validateModification();
                                })
                            : SizedBox.shrink(),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    InfoEntryLarge(
                      controller: medicalC,
                      label: AppLocalizations.of(context)!.medical_history,
                      readOnly: enabled,
                    ),
                    InfoEntryLarge(
                      controller: surgeryC,
                      label: AppLocalizations.of(context)!.surgery_history,
                      readOnly: enabled,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    InfoEntryLarge(
                      controller: notesC,
                      label: AppLocalizations.of(context)!.notes,
                      readOnly: enabled,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        BasicFlyout(
                            warning:
                                AppLocalizations.of(context)!.delete_warning,
                            onProceed: deletePatient,
                            action:
                                AppLocalizations.of(context)!.delete_confirm,
                            buttonText:
                                AppLocalizations.of(context)!.delete_patient)
                      ],
                    )
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
