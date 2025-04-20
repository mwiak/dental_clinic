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

import '../../shared/custom_widgets/text_boxes.dart';

class MultipleTeethImplantMenu extends StatefulWidget {
  final int patientId;
  final List codes;
  final SqlDb dataHelper;
  const MultipleTeethImplantMenu(
      {super.key,
      required this.patientId,
      required this.codes,
      required this.dataHelper});

  @override
  State<MultipleTeethImplantMenu> createState() =>
      MultipleTeethImplantMenuState();
}

class MultipleTeethImplantMenuState extends State<MultipleTeethImplantMenu> {
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
    setState(() {});
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
    String codes = jsonEncode(widget.codes);
    int response = await widget.dataHelper.insertData(
        '''INSERT INTO implants (patient_id,tooth_code,type,details,dates,date,cost,notes) 
    VALUES (${widget.patientId},'$codes','$selectedType','$details', '$dates','${dateC.text}', $cost, '$notes') ''');
    return response;
  }

  //get

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

  @override
  void initState() {
    super.initState();
    getAllTreatmentsWithFieldsWithOptions();
    getAllTreatmentsTypes();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 10,
        ),
        ComboBox(
            value: selectedType,
            onChanged: (val) {
              textControllersForCustomFields = [];
              dateControllersForCustomFields = [];
              setState(() {
                selectedType = val;
              });
            },
            placeholder: Text(AppLocalizations.of(context)!.select_implant),
            items: typeItems),
        SizedBox(
          height: 15,
        ),
        generateTypeForm(),
        SizedBox(
          height: 5,
        ),
        DatePickerBasic(
            label: AppLocalizations.of(context)!.date_adding, value: dateC),
        SizedBox(
          height: 5,
        ),
        CostBox(controller: costC, label: AppLocalizations.of(context)!.costs),
        SizedBox(
          height: 5,
        ),
        InputText(
            controller: notesC, label: AppLocalizations.of(context)!.notes),
      ],
    );
  }
}
