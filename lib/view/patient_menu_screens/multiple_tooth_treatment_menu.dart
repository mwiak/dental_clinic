import 'dart:convert';

import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/shared/custom_widgets/add_treatment_widgets.dart';
import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/custom_widgets/cost_box.dart';
import 'package:dental_clinic/shared/custom_widgets/date_pickers.dart';
import 'package:dental_clinic/shared/custom_widgets/drop_downs.dart';
import 'package:dental_clinic/shared/custom_widgets/flyout.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../shared/custom_widgets/text_boxes.dart';
import '../../view_model/teeth_provider.dart';

class MultipleToothTreatmentMenu extends StatefulWidget {
  final int patientId;
  final List codes;
  final bool isGeneral;
  final SqlDb dataHelper;
  const MultipleToothTreatmentMenu(
      {super.key,
      required this.patientId,
      required this.codes,
      required this.dataHelper,
      required this.isGeneral});

  @override
  State<MultipleToothTreatmentMenu> createState() =>
      MultipleToothTreatmentMenuState();
}

class MultipleToothTreatmentMenuState
    extends State<MultipleToothTreatmentMenu> {
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
          readOnly: false,
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

  void validateRequiredFields() async {
    if (selectedType != null && dateC.text != '' && costC.text.isNotEmpty) {
      num cost = num.parse(costC.text.trim());
      String details = jsonEncode(formatCustomFieldsValues());
      String codes = jsonEncode(widget.codes);

      String notes = notesC.text.trim();
      int response =
          await saveNewTreatment(details, codes, dateC.text, cost, notes);
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
      String details, String codes, String date, num cost, String notes) async {
    int response = await widget.dataHelper.insertData(
        '''INSERT INTO treatments (patient_id,tooth_code,treatment,details,date,cost,notes) 
    VALUES (${widget.patientId},'$codes','$selectedType','$details', '$date', $cost, '$notes') ''');
    return response;
  }

  //get

  void validateModify(int id) {
    if (dateC.text.isNotEmpty && costC.text.isNotEmpty) {
      String date = dateC.text;
      num cost = num.parse(costC.text);
      String notes = notesC.text.trim();
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
                validateRequiredFields();
              },
            ),
          ],
        );
      }),
    );

    selectedType = null;
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
              controllersForCustomFields = [];
              setState(() {
                selectedType = val;
              });
            },
            placeholder: Text(AppLocalizations.of(context)!.select_treatment),
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
