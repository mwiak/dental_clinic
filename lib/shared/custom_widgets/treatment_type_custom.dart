import 'dart:convert';

import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/shared/custom_widgets/flyout.dart';
import 'package:dental_clinic/shared/custom_widgets/treatments_field.dart';
import 'package:dental_clinic/view_model/custome_field_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'barboxes.dart';
import 'option_entry.dart';
import 'text_boxes.dart';

class TreatmentFieldDropDown extends StatefulWidget {
  final Map typeData;
  const TreatmentFieldDropDown({super.key, required this.typeData});

  @override
  State<TreatmentFieldDropDown> createState() => _TreatmentFieldDropDownState();
}

class _TreatmentFieldDropDownState extends State<TreatmentFieldDropDown> {
  SqlDb dataHelper = SqlDb();
  String type = '';
  late IconData icon;
  late String label;
  late List options;
  late int fieldId;

  void setUp() {
    label = widget.typeData['field_name'];
    fieldId = widget.typeData['id'];
    setState(() {});
  }

  Future<void> deleteField() async {
    int response = await dataHelper
        .deleteData('''DELETE FROM custom_fields WHERE id = $fieldId''');
    if (response > 0) {
      Provider.of<CustomFieldProvider>(context, listen: false).notify();
    } else {}
  }

  Future<List> getOptions() async {
    List<Map<String, dynamic>> data = await dataHelper.readData(
        ''' SELECT * FROM field_options WHERE custom_field_id = ${widget.typeData['id']} ''');
    options = data.map((Map x) {
      return x['option_value'];
    }).toList();
    return data;
  }

  Future<void> modifyOptions(List<TextEditingController> options) async {
    int deleteflag = await deletePreviousOptions();
    if (deleteflag > 0) {
      for (TextEditingController option in options) {
        await dataHelper.insertData(
            '''INSERT INTO field_options (custom_field_id,option_value) VALUES ($fieldId,'${option.text}')''');
      }
    }
  }

  Future<int> deletePreviousOptions() async {
    int deleteFlag = await dataHelper.deleteData(
        '''DELETE FROM field_options WHERE custom_field_id = $fieldId ''');
    return deleteFlag;
  }

  Future<void> modifyFieldName(String newName) async {
    int response = await dataHelper.updateData(
        '''UPDATE custom_fields SET field_name = '$newName' WHERE id = $fieldId  ''');
  }

  void validateOptions(
      List<TextEditingController> options, String newName) async {
    bool flag = true;
    if (options.isNotEmpty) {
      for (TextEditingController option in options) {
        flag = option.text.isNotEmpty;
        if (flag == false) {
          break;
        }
      }

      if (flag) {
        await modifyFieldName(newName);
        await modifyOptions(options);
        Provider.of<CustomFieldProvider>(context, listen: false).notify();
        Navigator.of(context).pop();
      } else {
        showBar(context, AppLocalizations.of(context)!.option_required,
            InfoBarSeverity.warning);
      }
    } else {
      showBar(context, AppLocalizations.of(context)!.dropdown_option_required,
          InfoBarSeverity.warning);
    }
  }

  void showModifyFieldDialog(BuildContext context) async {
    TextEditingController fieldNameC = TextEditingController(text: label);
    String? selectedType;
    List<TextEditingController> optionsControllers = options.map((option) {
      return TextEditingController(text: option);
    }).toList();
    print(options);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: BoxConstraints(
              minWidth: 200, minHeight: 200, maxHeight: 600, maxWidth: 500),
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.modify_field),
              Spacer(),
              BasicFlyout(
                  warning: AppLocalizations.of(context)!.generic_warning,
                  onProceed: () async {
                    await deleteField();
                    Navigator.of(context).pop();
                  },
                  action:
                      AppLocalizations.of(context)!.generic_delete_confirmation,
                  buttonText: AppLocalizations.of(context)!.generic_delete)
            ],
          ),
          content: Column(
            children: [
              InputText(
                  controller: fieldNameC,
                  label: AppLocalizations.of(context)!.field_name),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 15,
              ),
              Column(
                children: [
                  SizedBox(
                      width: 300,
                      height: 260,
                      child: ListView.builder(
                          itemCount: optionsControllers.length,
                          shrinkWrap: false,
                          itemBuilder: (context, i) {
                            return OptionEntry(
                              controller: optionsControllers[i],
                              onDelete: () {
                                optionsControllers.removeAt(i);
                                s(() {});
                              },
                            );
                          })),
                  FilledButton(
                      child: Text(AppLocalizations.of(context)!.add_option),
                      onPressed: () {
                        optionsControllers.add(TextEditingController());
                        s(() {});
                      }),
                ],
              )
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
              child: Text(AppLocalizations.of(context)!.save),
              onPressed: () {
                validateOptions(optionsControllers, fieldNameC.text);
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
    setUp();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(FluentIcons.dropdown),
            const SizedBox(
              width: 5,
            ),
            Text(
              AppLocalizations.of(context)!.dropdown_field,
              style: FluentTheme.of(context).typography.caption,
            ),
            SizedBox(
              width: 20,
            ),
            Text(label ?? ''),
            SizedBox(
              width: 50,
            ),
            Row(
              children: [
                Text(AppLocalizations.of(context)!.options),
                FutureBuilder(
                  future:
                      getOptions(), // Ensure `getOptions()` returns a Future<List<Map<String, dynamic>>>
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox
                          .shrink(); // Or SizedBox.shrink() if you prefer no loading indicator
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return Text(AppLocalizations.of(context)!.no_data);
                    } else {
                      // Build a list of Text widgets for each map
                      return Row(
                        children: snapshot.data!.map((map) {
                          // Adjust "map['key']" to access the desired value from your map
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2), // Add padding for spacing
                            child: Text(map['option_value'] ??
                                'No Value'), // Use a fallback for missing keys
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
            SizedBox(
              width: 30,
            ),
            IconButton(
                icon: Icon(FluentIcons.edit),
                onPressed: () {
                  showModifyFieldDialog(context);
                }),
            SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }
}

class TreatmentFieldText extends StatefulWidget {
  final Map typeData;
  const TreatmentFieldText({super.key, required this.typeData});

  @override
  State<TreatmentFieldText> createState() => _TreatmentFieldTextState();
}

class _TreatmentFieldTextState extends State<TreatmentFieldText> {
  SqlDb dataHelper = SqlDb();

  late int fieldId;
  late IconData icon;
  late String label;

  void setUp() {
    label = widget.typeData['field_name'];
    fieldId = widget.typeData['id'];
    setState(() {});
  }

  Future<void> deleteField() async {
    int response = await dataHelper
        .deleteData('''DELETE FROM custom_fields WHERE id = $fieldId''');
    if (response > 0) {
      Provider.of<CustomFieldProvider>(context, listen: false).notify();
    } else {}
  }

  Future<void> modifyFieldName(String newName) async {
    int response = await dataHelper.updateData(
        '''UPDATE custom_fields SET field_name = '$newName' WHERE id = $fieldId  ''');

    Provider.of<CustomFieldProvider>(context, listen: false).notify();
  }

  void showModifyFieldDialog(BuildContext context) async {
    TextEditingController fieldNameC = TextEditingController(text: label);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(
              minWidth: 200, minHeight: 200, maxHeight: 300, maxWidth: 400),
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.modify_field),
              Spacer(),
              BasicFlyout(
                  warning: AppLocalizations.of(context)!.generic_warning,
                  onProceed: () async {
                    await deleteField();
                    Navigator.of(context).pop();
                  },
                  action:
                      AppLocalizations.of(context)!.generic_delete_confirmation,
                  buttonText: AppLocalizations.of(context)!.generic_delete)
            ],
          ),
          content: Column(
            children: [
              InputText(
                  controller: fieldNameC,
                  label: AppLocalizations.of(context)!.field_name),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 15,
              ),
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
              child: Text(AppLocalizations.of(context)!.save),
              onPressed: () async {
                if (fieldNameC.text.isNotEmpty) {
                  await modifyFieldName(fieldNameC.text);
                  Navigator.of(context).pop();
                } else {
                  showBar(
                      context,
                      AppLocalizations.of(context)!.field_name_required,
                      InfoBarSeverity.warning);
                }
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
    setUp();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Card(
        child: Row(
          children: [
            Icon(FluentIcons.text_field),
            const SizedBox(
              width: 5,
            ),
            Text(
              AppLocalizations.of(context)!.text_field,
              style: FluentTheme.of(context).typography.caption,
            ),
            SizedBox(
              width: 20,
            ),
            Text(label ?? ''),
            SizedBox(
              width: 30,
            ),
            IconButton(
                icon: Icon(FluentIcons.edit),
                onPressed: () {
                  showModifyFieldDialog(context);
                }),
            SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }
}
