import 'package:dental_clinic/view_model/teeth_implant_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'dart:convert';

import 'package:dental_clinic/database/sqflite.dart';

import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/custom_widgets/cost_box.dart';
import 'package:dental_clinic/shared/custom_widgets/date_pickers.dart';
import 'package:dental_clinic/shared/custom_widgets/drop_downs.dart';
import 'package:dental_clinic/shared/custom_widgets/flyout.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../shared/custom_widgets/multiple_teeth_show.dart';
import '../../shared/custom_widgets/text_boxes.dart';

class ImplantsToothMenu extends StatefulWidget {
  final int patientId;
  final int toothCode;
  final SqlDb dataHelper;
  const ImplantsToothMenu(
      {super.key,
      required this.patientId,
      required this.toothCode,
      required this.dataHelper});

  @override
  State<ImplantsToothMenu> createState() => _ImplantsToothMenuState();
}

class _ImplantsToothMenuState extends State<ImplantsToothMenu> {
  String? selectedType;
  TextEditingController dateC = TextEditingController();
  TextEditingController costC = TextEditingController();
  TextEditingController notesC = TextEditingController();

  List<ComboBoxItem> typeItems = [];

  List<Map<String, dynamic>> textControllersForCustomFields = [];

  List<Map<String, dynamic>> dateControllersForCustomFields = [];

  List typesData = [];

  Future<void> getAllTreatmentsWithFieldsWithOptions() async {
    List data =
        await widget.dataHelper.readData('''SELECT * FROM implants_types''');
    List result = [];

    for (Map type in data) {
      int typeId = type['id'];
      String typeName = type['name'];
      List fiellds = [];
      Map treatmentType = {typeName: fiellds};
      List data1 = await widget.dataHelper.readData(
          '''SELECT * FROM custom_fields_implants WHERE implant_type_id = $typeId''');
      for (Map field in data1) {
        int fieldId = field['id'];
        String fieldName = field['field_name'];
        String fieldType = field['field_type'];
        if (fieldType == 'dropdown' || fieldType == 'date') {
          List options = await widget.dataHelper.readData(
              '''SELECT * FROM field_options_implants WHERE custom_field_id = $fieldId''');
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
        await widget.dataHelper.readData('''SELECT * FROM implants_types''');
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
          textControllersForCustomFields.add({fieldName: value});
          result.add(DropDown(
            label: fieldName,
            options: options,
            value: value,
          ));
          result.add(SizedBox(
            height: 5,
          ));
        } else if (fieldType == 'text') {
          TextEditingController controller = TextEditingController();
          textControllersForCustomFields.add({fieldName: controller});
          result.add(InputText(controller: controller, label: fieldName));
          result.add(SizedBox(
            height: 5,
          ));
        } else {
          TextEditingController controller = TextEditingController();
          dateControllersForCustomFields.add({fieldName: controller});
          result.add(DatePickerNullable(
            label: fieldName,
            value: controller,
          ));
          result.add(SizedBox(
            height: 5,
          ));
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
        textControllersForCustomFields.add({pair.keys.first: controller});
        result.add(InfoEntrySmall(
          controller: controller,
          label: pair.keys.first,
          readOnly: true,
        ));
      }
    }

    return Column(children: result);
  }

  Widget generateDatesForm(List dates) {
    List<Widget> result = [];
    if (dates.isNotEmpty) {
      for (Map pair in dates) {
        TextEditingController controller =
            TextEditingController(text: pair.values.first);
        dateControllersForCustomFields.add({pair.keys.first: controller});
        result.add(DatePickerNullable(
          value: controller,
          label: pair.keys.first,
          date: pair.values.first,
        ));
      }
    }

    return Column(children: result);
  }

  Future<List> getTypeFields(String selectedType) async {
    List data = await widget.dataHelper.readData(
        '''SELECT * FROM implants_types WHERE name = '$selectedType' ''');

    int selectedTypeId = data[0]['id'];
    List data2 = await widget.dataHelper.readData(
        '''SELECT * FROM custom_fields_implants WHERE implant_type_id = $selectedTypeId ''');

    return data2;
  }

  List formatTextCustomFieldsValues() {
    List data = [];
    for (Map field in textControllersForCustomFields) {
      String label = field.keys.first;
      var valueSource = field.values.first;
      String value = '';
      value = valueSource.text ?? '';
      data.add({label: value});
    }
    return data;
  }

  List formatDateCustomFieldsValues() {
    List data = [];
    for (Map field in dateControllersForCustomFields) {
      String label = field.keys.first;
      var valueSource = field.values.first;
      String value = '';
      value = valueSource.text ?? '';
      data.add({label: value});
    }

    return data;
  }

  //saving

  void validateRequiredFields() async {
    if (selectedType != null && costC.text.isNotEmpty) {
      num cost = num.parse(costC.text.trim());
      String details = jsonEncode(formatTextCustomFieldsValues());
      String dates = jsonEncode(formatDateCustomFieldsValues());
      String notes = notesC.text.trim();
      int response = await saveNewImplant(details, dates, cost, notes);
      if (response > 0) {
        showBar(context, 'added', InfoBarSeverity.success);
        Provider.of<TeethImplantProvider>(context, listen: false).notify();
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

  Future<int> saveNewImplant(
      String details, String dates, num cost, String notes) async {
    List codes = [widget.toothCode];
    String code = jsonEncode(codes);
    int response = await widget.dataHelper.insertData(
        '''INSERT INTO implants (patient_id,tooth_code,type,details,dates,date,cost,notes) 
    VALUES (${widget.patientId},'$code','$selectedType','$details', '$dates','${dateC.text}', $cost, '$notes') ''');
    return response;
  }

  //get

  Future<List> getAllTreatments() async {
    List data = await widget.dataHelper.readData(
        ''' SELECT * FROM implants WHERE patient_id = ${widget.patientId} AND EXISTS (
    SELECT 1
    FROM json_each(tooth_code)
    WHERE value = ${widget.toothCode}
  )''');
    return data;
  }

  Future<num> getToothTotalCost() async {
    List data = await widget.dataHelper.readData(
        ''' SELECT SUM(cost) as total FROM implants WHERE patient_id = ${widget.patientId} AND EXISTS (
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
        .deleteData('''DELETE FROM implants WHERE id = $id  ''');
    if (response > 0) {
      Provider.of<TeethImplantProvider>(context, listen: false).notify();
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  //modify
  Future<void> modifyImplant(
      int id, num cost, String dates, String details, String notes) async {
    int response = await widget.dataHelper.updateData(
        ''' UPDATE implants SET dates = '$dates', details = '$details' ,cost = $cost ,notes = '$notes' WHERE id = $id''');
    if (response > 0) {
      Provider.of<TeethImplantProvider>(context, listen: false).notify();
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  void validateModify(int id) {
    if (costC.text.isNotEmpty) {
      String dates = jsonEncode(formatDateCustomFieldsValues());
      String details = jsonEncode(formatTextCustomFieldsValues());
      num cost = num.parse(costC.text);
      String notes = notesC.text.trim();
      modifyImplant(id, cost, dates, details, notes);
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
          title: Text(AppLocalizations.of(context)!.add_new_implant),
          content: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              ComboBox(
                  value: selectedType,
                  onChanged: (val) {
                    textControllersForCustomFields = [];
                    dateControllersForCustomFields = [];
                    s(() {
                      selectedType = val;
                    });
                  },
                  placeholder:
                      Text(AppLocalizations.of(context)!.select_implant),
                  items: typeItems),
              SizedBox(
                height: 15,
              ),
              generateTypeForm(),
              SizedBox(
                height: 5,
              ),
              DatePickerBasic(
                  label: AppLocalizations.of(context)!.date_adding,
                  value: dateC),
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
    dateControllersForCustomFields = [];
    textControllersForCustomFields = [];

    costC.clear();
    notesC.clear();
  }

  void showModifyTreatmentDialog(BuildContext context, Map implantData) async {
    selectedType = implantData['type'];

    costC.text = implantData['cost'].toStringAsFixed(2);
    notesC.text = implantData['notes'] ?? '';
    List details = jsonDecode(implantData['details'] ?? '');
    List dates = jsonDecode(implantData['dates'] ?? '');
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(
              minWidth: 200, minHeight: 200, maxHeight: 600, maxWidth: 500),
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.modify_implant),
              Spacer(),
              BasicFlyout(
                  warning: AppLocalizations.of(context)!.generic_warning,
                  onProceed: () {
                    deleteTreatment(implantData['id']);
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
                height: 10,
              ),
              generateDatesForm(dates),
              SizedBox(
                height: 15,
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
                validateModify(implantData['id']);
              },
            ),
          ],
        );
      }),
    );

    selectedType = null;
    dateControllersForCustomFields = [];
    textControllersForCustomFields = [];

    costC.clear();
    notesC.clear();
  }

  void showMultipleTreatmentDialog(BuildContext context, List codes) async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(
              minWidth: 200, minHeight: 200, maxHeight: 400, maxWidth: 900),
          title: Text('الأسنان المرتبطة بالزرعة'),
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
                  text: AppLocalizations.of(context)!.implants_for,
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
                                        child: Text(snapshot.data![i]['type']),
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
                                              child: Text('زرعة مشتركة'),
                                            )
                                          : SizedBox.shrink()),
                                  Align(
                                    alignment: Alignment.bottomRight,
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
