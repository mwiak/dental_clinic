import 'package:dental_clinic/database/sqflite.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/custom_widgets/barboxes.dart';
import '../../shared/custom_widgets/cost_box.dart';
import '../../shared/custom_widgets/date_pickers.dart';
import '../../shared/custom_widgets/flyout.dart';
import '../../shared/custom_widgets/text_boxes.dart';

class GeneralTreatmentsMenu extends StatefulWidget {
  final int patientId;
  const GeneralTreatmentsMenu({super.key, required this.patientId});

  @override
  State<GeneralTreatmentsMenu> createState() => _GeneralTreatmentsMenuState();
}

class _GeneralTreatmentsMenuState extends State<GeneralTreatmentsMenu> {
  SqlDb dataHelper = SqlDb();
  List<ComboBoxItem> typeItems = [];
  String? selectedType;
  TextEditingController dateC = TextEditingController();
  TextEditingController costC = TextEditingController();
  TextEditingController notesC = TextEditingController();

  Future<void> getAllTreatmentsTypes() async {
    List data =
        await dataHelper.readData('''SELECT * FROM general_treatments_types''');
    typeItems = data.map((type) {
      return ComboBoxItem(
        value: type['type'],
        child: Text(type['type']),
      );
    }).toList();
  }

  Future<List> getAllTreatments() async {
    List data = await dataHelper.readData(
        ''' SELECT * FROM general_treatments WHERE patient_id = ${widget.patientId} ''');
    return data;
  }

  Future<num> getToothTotalCost() async {
    List data = await dataHelper.readData(
        ''' SELECT SUM(cost) as total FROM general_treatments WHERE patient_id = ${widget.patientId} ''');
    num total = data[0]['total'] ?? 0;

    return total;
  }

  Future<int> saveNewTreatment(String date, num cost, String notes) async {
    int response = await dataHelper.insertData(
        '''INSERT INTO general_treatments (patient_id,treatment_type,date,cost,notes) 
    VALUES (${widget.patientId},'$selectedType','$date', $cost, '$notes') ''');
    return response;
  }

  void validateRequiredFields() async {
    if (selectedType != null && dateC.text != '' && costC.text.isNotEmpty) {
      num cost = num.parse(costC.text.trim());

      String notes = notesC.text.trim();
      int response = await saveNewTreatment(dateC.text, cost, notes);
      if (response > 0) {
        showBar(context, 'added', InfoBarSeverity.success);
        Navigator.of(context).pop();
        setState(() {});
      } else {
        showBar(context, 'not added', InfoBarSeverity.error);
      }
    } else {
      showBar(context, '* is required', InfoBarSeverity.warning);
    }
  }

  Future<void> modifyTreatment(
      int id, String date, num cost, String notes) async {
    int response = await dataHelper.updateData(
        ''' UPDATE general_treatments SET date = '$date', cost = $cost ,notes = '$notes' WHERE id = $id''');
    if (response > 0) {
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  void validateModify(int id) {
    if (dateC.text.isNotEmpty && costC.text.isNotEmpty) {
      String date = dateC.text;
      num cost = num.parse(costC.text);
      String notes = notesC.text.trim();
      modifyTreatment(id, date, cost, notes);
    } else {
      showBar(context, '* cant be empty', InfoBarSeverity.warning);
    }
  }

  Future<void> deleteTreatment(int id) async {
    int response = await dataHelper
        .deleteData('''DELETE FROM general_treatments WHERE id = $id  ''');
    if (response > 0) {
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  void showAddTreatmentDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(
              minWidth: 200, minHeight: 200, maxHeight: 600, maxWidth: 500),
          title: Text(AppLocalizations.of(context)!.add_general_treatment),
          content: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              ComboBox(
                  value: selectedType,
                  onChanged: (val) {
                    s(() {
                      selectedType = val;
                    });
                  },
                  placeholder:
                      Text(AppLocalizations.of(context)!.select_treatment),
                  items: typeItems),
              SizedBox(
                height: 15,
              ),
              DatePickerBasic(
                label: AppLocalizations.of(context)!.treatment_date,
                value: dateC,
              ),
              SizedBox(
                height: 5,
              ),
              CostBox(
                  controller: costC,
                  label: AppLocalizations.of(context)!.costs),
              SizedBox(
                height: 5,
              ),
              InputText(
                  controller: notesC,
                  label: AppLocalizations.of(context)!.notes),
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
                validateRequiredFields();
              },
            ),
          ],
        );
      }),
    );

    selectedType = null;
    costC.clear();
    dateC.clear();
    notesC.clear();
  }

  void showModifyTreatmentDialog(
      BuildContext context, Map treatmentData) async {
    selectedType = treatmentData['treatment_type'];
    dateC.text = treatmentData['date'];
    costC.text = treatmentData['cost'].toStringAsFixed(2);
    notesC.text = treatmentData['notes'] ?? '';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.modify_treatment),
              Spacer(),
              BasicFlyout(
                  warning: AppLocalizations.of(context)!.generic_warning,
                  onProceed: () {
                    deleteTreatment(treatmentData['id']);
                  },
                  action:
                      AppLocalizations.of(context)!.generic_delete_confirmation,
                  buttonText: AppLocalizations.of(context)!.generic_delete)
            ],
          ),
          content: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              ComboBox(value: selectedType, items: typeItems),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 15,
              ),
              DatePickerNullable(
                label: AppLocalizations.of(context)!.treatment_date,
                value: dateC,
                date: dateC.text,
              ),
              SizedBox(
                height: 5,
              ),
              CostBox(
                  controller: costC,
                  label: AppLocalizations.of(context)!.costs),
              SizedBox(
                height: 5,
              ),
              InputText(
                  controller: notesC,
                  label: AppLocalizations.of(context)!.notes),
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
                validateModify(treatmentData['id']);
              },
            ),
          ],
        );
      }),
    );

    selectedType = null;
    costC.clear();
    dateC.clear();
    notesC.clear();
  }

  @override
  void initState() {
    super.initState();
    getAllTreatmentsTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(AppLocalizations.of(context)!.total),
                FutureBuilder(
                    future: getToothTotalCost(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox.shrink();
                      } else if (snapshot.hasError) {
                        return SizedBox.shrink();
                      } else if (snapshot.data == 0) {
                        return Text(AppLocalizations.of(context)!.no_data);
                      } else {
                        return Text(snapshot.data!.toStringAsFixed(2) + ' \$');
                      }
                    })
              ],
            ),
            const Spacer(),
            Text.rich(
              TextSpan(
                  text: AppLocalizations.of(context)!.general_treatments,
                  children: []),
            ),
            const Spacer(),
            FilledButton(
                child: Text(AppLocalizations.of(context)!.add),
                onPressed: () {
                  showAddTreatmentDialog(context);
                })
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Divider(),
        SizedBox(
          height: 20,
        ),
        Expanded(
            child: FutureBuilder(
                future: getAllTreatments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox.shrink();
                  } else if (snapshot.hasError) {
                    return SizedBox.shrink();
                  } else if (snapshot.data!.isEmpty) {
                    return SizedBox.shrink();
                  } else {
                    return ListView.separated(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                          child: SizedBox(
                              height: 60,
                              child: Stack(
                                children: [
                                  Align(
                                    child: FilledButton(
                                        child: Text(snapshot.data![i]
                                            ['treatment_type']),
                                        onPressed: () {
                                          showModifyTreatmentDialog(
                                              context, snapshot.data![i]);
                                        }),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(snapshot.data![i]['cost']
                                        .toStringAsFixed(2)),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(snapshot.data![i]['date']),
                                  ),
                                ],
                              )),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox.shrink();
                      },
                    );
                  }
                }))
      ],
    );
  }
}
