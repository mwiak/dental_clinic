import 'dart:convert';

import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/shared/custom_widgets/add_treatment_widgets.dart';
import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/custom_widgets/cost_box.dart';
import 'package:dental_clinic/shared/custom_widgets/date_pickers.dart';
import 'package:dental_clinic/shared/custom_widgets/drop_downs.dart';
import 'package:dental_clinic/shared/custom_widgets/flyout.dart';
import 'package:dental_clinic/view_model/teeth_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../shared/custom_widgets/multiple_teeth_show.dart';
import '../../shared/custom_widgets/text_boxes.dart';

class TreatmentToothMenu extends StatefulWidget {
  final int patientId;
  final int toothCode;
  final SqlDb dataHelper;
  const TreatmentToothMenu(
      {super.key,
      required this.patientId,
      required this.toothCode,
      required this.dataHelper});

  @override
  State<TreatmentToothMenu> createState() => _TreatmentToothMenuState();
}

class _TreatmentToothMenuState extends State<TreatmentToothMenu> {
  String? selectedType;
  TextEditingController dateC = TextEditingController();
  TextEditingController costC = TextEditingController();
  TextEditingController notesC = TextEditingController();

  List<ComboBoxItem> typeItems = [];

  List<Map<String, dynamic>> controllersForCustomFields = [];

  List typesData = [];

  Future<void> getAllTreatmentsWithFieldsWithOptions() async {
    List data =
        await widget.dataHelper.readData('''SELECT * FROM treatment_types''');
    List result = [];

    for (Map type in data) {
      int typeId = type['id'];
      String typeName = type['name'];
      List fiellds = [];
      Map treatmentType = {typeName: fiellds};
      List data1 = await widget.dataHelper.readData(
          '''SELECT * FROM custom_fields WHERE treatment_type_id = $typeId''');
      for (Map field in data1) {
        int fieldId = field['id'];
        String fieldName = field['field_name'];
        String fieldType = field['field_type'];
        if (fieldType == 'dropdown') {
          List options = await widget.dataHelper.readData(
              '''SELECT * FROM field_options WHERE custom_field_id = $fieldId''');
          Map fieldData = {
            'fieldName': fieldName,
            'fieldType': fieldType,
            'fieldOptions': options
          };
          fiellds.add(fieldData);
        } else {
          Map fieldData = {
            'fieldName': fieldName,
            'fieldType': fieldType,
          };
          fiellds.add(fieldData);
        }
      }
      result.add(treatmentType);
    }

    typesData = result;
  }

  Future<void> getAllTreatmentsTypes() async {
    List data =
        await widget.dataHelper.readData('''SELECT * FROM treatment_types''');
    typeItems = data.map((type) {
      return ComboBoxItem(
        value: type['name'],
        child: Text(type['name']),
      );
    }).toList();
  }

  Widget generateTypeForm() {
    List<Widget> result = [];
    if (selectedType != null) {
      Map fieldsD = typesData
          .where((element) => element.keys.first.contains(selectedType))
          .toList()
          .first;
      List fields = fieldsD.values.first;
      for (Map field in fields) {
        String fieldType = field['fieldType'];
        String fieldName = field['fieldName'];
        if (fieldType == 'dropdown') {
          TextEditingController value = TextEditingController();
          List options = field['fieldOptions'];
          controllersForCustomFields.add({fieldName: value});
          result.add(DropDown(
            label: fieldName,
            options: options,
            value: value,
          ));
        } else {
          TextEditingController controller = TextEditingController();
          controllersForCustomFields.add({fieldName: controller});
          result.add(InputText(controller: controller, label: fieldName));
        }
      }
    }

    return Column(children: result);
  }

  Widget generateDetailsForm(List details) {
    List<Widget> result = [];
    if (details.isNotEmpty) {
      for (Map pair in details) {
        TextEditingController controller =
            TextEditingController(text: pair.values.first);
        controllersForCustomFields.add({pair.keys.first: controller});
        result.add(InfoEntrySmall(
          controller: controller,
          label: pair.keys.first,
          readOnly: true,
        ));
      }
    }

    return Column(children: result);
  }

  Future<List> getTypeFields(String selectedType) async {
    List data = await widget.dataHelper.readData(
        '''SELECT * FROM treatment_types WHERE name = '$selectedType' ''');

    int selectedTypeId = data[0]['id'];
    List data2 = await widget.dataHelper.readData(
        '''SELECT * FROM custom_fields WHERE treatment_type_id = $selectedTypeId ''');

    return data2;
  }

  List formatCustomFieldsValues() {
    List data = [];
    for (Map field in controllersForCustomFields) {
      String label = field.keys.first;
      var valueSource = field.values.first;
      String value = '';
      value = valueSource.text ?? '';
      data.add({label: value});
    }
    return data;
  }

  //saving

  void validateRequiredFields(BuildContext context) async {
    if (selectedType != null && dateC.text != '' && costC.text.isNotEmpty) {
      num cost = num.parse(costC.text.trim());
      String details = jsonEncode(formatCustomFieldsValues());

      String notes = notesC.text.trim();
      int response = await saveNewTreatment(details, dateC.text, cost, notes);
      if (response > 0) {
        showBar(context, AppLocalizations.of(context)!.success,
            InfoBarSeverity.success);
        Provider.of<TeethProvider>(context, listen: false).notify();
        Navigator.of(context).pop();
        setState(() {});
      } else {
        showBar(context, AppLocalizations.of(context)!.failed,
            InfoBarSeverity.error);
      }
    } else {
      showBar(context, AppLocalizations.of(context)!.title_required,
          InfoBarSeverity.warning);
    }
  }

  Future<int> saveNewTreatment(
      String details, String date, num cost, String notes) async {
    List codes = [widget.toothCode];
    String code = jsonEncode(codes);
    print(code);
    int response = await widget.dataHelper.insertData(
        '''INSERT INTO treatments (patient_id,tooth_code,treatment,details,date,cost,notes) 
    VALUES (${widget.patientId},'${code}','$selectedType','$details', '$date', $cost, '$notes') ''');
    return response;
  }

  //get

  Future<List> getAllTreatments() async {
    List data = await widget.dataHelper.readData(
        ''' SELECT * FROM treatments WHERE patient_id = ${widget.patientId} AND EXISTS (
    SELECT 1
    FROM json_each(tooth_code)
    WHERE value = ${widget.toothCode}
  )''');
    return data;
  }

  Future<num> getToothTotalCost() async {
    List data = await widget.dataHelper.readData(
        ''' SELECT SUM(cost) as total FROM treatments WHERE patient_id = ${widget.patientId} AND EXISTS (
    SELECT 1
    FROM json_each(tooth_code)
    WHERE value = ${widget.toothCode}
  )''');
    num total = data[0]['total'] ?? 0;

    return total;
  }

  //delete
  Future<void> deleteTreatment(int id) async {
    int response = await widget.dataHelper
        .deleteData('''DELETE FROM treatments WHERE id = $id  ''');
    if (response > 0) {
      Provider.of<TeethProvider>(context, listen: false).notify();
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  //modify
  Future<void> modifyTreatment(BuildContext context, int id, String date,
      num cost, String notes, String details) async {
    int response = await widget.dataHelper.updateData(
        ''' UPDATE treatments SET date = '$date', cost = $cost ,notes = '$notes', details = '$details' WHERE id = $id''');
    if (response > 0) {
      Provider.of<TeethProvider>(context, listen: false).notify();
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  void validateModify(BuildContext context, int id) {
    if (dateC.text.isNotEmpty && costC.text.isNotEmpty) {
      String date = dateC.text;
      num cost = num.parse(costC.text);
      String notes = notesC.text.trim();
      String details = jsonEncode(formatCustomFieldsValues());

      modifyTreatment(context, id, date, cost, notes, details);
    } else {
      showBar(context, AppLocalizations.of(context)!.title_required,
          InfoBarSeverity.warning);
    }
  }

  void showAddTreatmentDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(
              minWidth: 200, minHeight: 200, maxHeight: 600, maxWidth: 500),
          title: Text(AppLocalizations.of(context)!.add_treatment),
          content: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              ComboBox(
                  value: selectedType,
                  onChanged: (val) {
                    controllersForCustomFields = [];
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
              generateTypeForm(),
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
                validateRequiredFields(context);
              },
            ),
          ],
        );
      }),
    );

    selectedType = null;
    controllersForCustomFields = [];
    costC.clear();
    notesC.clear();
  }

  void showModifyTreatmentDialog(
      BuildContext context, Map treatmentData) async {
    selectedType = treatmentData['treatment'];
    dateC.text = treatmentData['date'];
    costC.text = treatmentData['cost'].toStringAsFixed(2);
    notesC.text = treatmentData['notes'] ?? '';
    List details = jsonDecode(treatmentData['details'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(
              minWidth: 200, minHeight: 200, maxHeight: 600, maxWidth: 500),
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
              generateDetailsForm(details),
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
                Navigator.pop(context, 'User deleted file');
                // Delete file here
              },
            ),
            FilledButton(
              child: Text(AppLocalizations.of(context)!.generic_modify),
              onPressed: () {
                validateModify(context, treatmentData['id']);
              },
            ),
          ],
        );
      }),
    );

    selectedType = null;
    controllersForCustomFields = [];
    costC.clear();
    dateC.clear();
    notesC.clear();
  }

  void showMultipleTreatmentDialog(BuildContext context, List codes) async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(
              minWidth: 200, minHeight: 200, maxHeight: 400, maxWidth: 900),
          title: Text('الأسنان المرتبطة بالعلاج'),
          content: ListView(children: [
            MultipleTeethShow(
              codes: codes,
            )
          ]),
          actions: [
            Button(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.pop(context, 'User deleted file');

                // Delete file here
              },
            ),
          ],
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    getAllTreatmentsWithFieldsWithOptions();
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
                  text: AppLocalizations.of(context)!.treatments_for,
                  children: [
                    const TextSpan(text: ' '),
                    TextSpan(text: widget.toothCode.toString())
                  ]),
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
                        List codes =
                            jsonDecode(snapshot.data![i]['tooth_code']);
                        bool isMultiple = codes.length > 1;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                          child: SizedBox(
                              height: 60,
                              child: Stack(
                                children: [
                                  Align(
                                    child: FilledButton(
                                        child: Text(
                                            snapshot.data![i]['treatment']),
                                        onPressed: () {
                                          showModifyTreatmentDialog(
                                              context, snapshot.data![i]);
                                        }),
                                  ),
                                  Positioned(
                                      top: 1,
                                      right: 2,
                                      child: isMultiple
                                          ? OutlinedButton(
                                              onPressed: () {
                                                showMultipleTreatmentDialog(
                                                    context, codes);
                                              },
                                              child: Text('علاج مشترك'),
                                            )
                                          : SizedBox.shrink()),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(snapshot.data![i]['date']),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(snapshot.data![i]['cost']
                                        .toStringAsFixed(2)),
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
