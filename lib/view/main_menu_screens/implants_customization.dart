import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/custom_widgets/flyout.dart';
import 'package:dental_clinic/shared/custom_widgets/option_entry.dart';
import 'package:dental_clinic/view/main_screen.dart';
import 'package:dental_clinic/view_model/custome_field_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../shared/custom_widgets/implant_type_custom.dart';
import '../../shared/custom_widgets/text_boxes.dart';

class ImplantsCustomization extends StatefulWidget {
  const ImplantsCustomization({super.key});

  @override
  State<ImplantsCustomization> createState() => _ImplantsCustomizationState();
}

class _ImplantsCustomizationState extends State<ImplantsCustomization> {
  SqlDb dataHelper = SqlDb();

  int? selectedType;

  void selectType(int input) {
    setState(() {
      selectedType = input;
    });
  }

  Future<List> getImplantsTypes() async {
    List data = await dataHelper.readData(''' SELECT * FROM implants_types''');
    return data;
  }

  Future<void> addNewImplantType(String name) async {
    await dataHelper
        .insertData('''INSERT INTO implants_types (name) VALUES ('$name') ''');
  }

  void validateAddImplant(String name) async {
    if (name != '') {
      addNewImplantType(name);
      Navigator.of(context).pop();
      setState(() {});
    } else {
      showBar(context, AppLocalizations.of(context)!.title_required,
          InfoBarSeverity.warning);
    }
  }

  Future<void> deleteImplantType() async {
    await dataHelper
        .deleteData(''' DELETE FROM implants_types WHERE id = $selectedType''');
    selectedType = null;
    setState(() {});
  }

  Future<List> getImplantFields(int input) async {
    List data = await dataHelper.readData(
        ''' SELECT * FROM custom_fields_implants WHERE implant_type_id = $input''');

    return data;
  }

  void validateOptions(
      String name, String type, List<TextEditingController> options) {
    bool flag = true;
    if (options.isNotEmpty) {
      for (TextEditingController option in options) {
        flag = option.text.isNotEmpty;
        if (flag == false) {
          break;
        }
      }
      if (flag) {
        saveOptions(name, type, options);
      } else {
        showBar(context, AppLocalizations.of(context)!.option_required,
            InfoBarSeverity.warning);
      }
    } else {
      showBar(context, AppLocalizations.of(context)!.dropdown_option_required,
          InfoBarSeverity.warning);
    }
  }

  Future<int> saveField(String name, String type) async {
    int response = await dataHelper.insertData(
        '''INSERT INTO custom_fields_implants (implant_type_id,field_name,field_type) VALUES ($selectedType,'$name','$type')''');
    return response;
  }

  Future<void> saveTextField(String name, String type) async {
    int response = await saveField(name, type);
    if (response > 0) {
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  Future<void> saveOptions(
      String name, String type, List<TextEditingController> options) async {
    int savedFieldId = await saveField(name, type);
    if (savedFieldId > 0) {
      for (TextEditingController option in options) {
        await dataHelper.insertData(
            '''INSERT INTO field_options_implants (custom_field_id,option_value) VALUES ($savedFieldId,'${option.text}')''');
      }
      showBar(context, 'added', InfoBarSeverity.success);
      Navigator.pop(context);
      setState(() {});
    }
  }

  void showAddImplantTypeDialog(BuildContext context) async {
    TextEditingController typeC = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(maxHeight: 400, maxWidth: 300),
          title: Text(AppLocalizations.of(context)!.add_implant_type),
          content: Column(
            children: [
              InputText(
                  controller: typeC,
                  label: AppLocalizations.of(context)!.implant_type_name),
              SizedBox(
                height: 10,
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
              child: Text(AppLocalizations.of(context)!.add),
              onPressed: () {
                validateAddImplant(typeC.text);
              },
            ),
          ],
        );
      }),
    );
  }

  void showAddFieldDialog(BuildContext context) async {
    TextEditingController fieldNameC = TextEditingController();
    String? selectedType;
    List<TextEditingController> options = [TextEditingController()];
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: BoxConstraints(
              minWidth: 200, minHeight: 200, maxHeight: 600, maxWidth: 500),
          title: Text(AppLocalizations.of(context)!.add_field),
          content: Column(
            children: [
              InputText(
                  controller: fieldNameC,
                  label: AppLocalizations.of(context)!.field_name),
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
                      Text(AppLocalizations.of(context)!.select_field_type),
                  items: [
                    ComboBoxItem(
                      child: Text(AppLocalizations.of(context)!.dropdown_field),
                      value: 'dropdown',
                    ),
                    ComboBoxItem(
                      child: Text(AppLocalizations.of(context)!.text_field),
                      value: 'text',
                    ),
                    ComboBoxItem(
                      child: Text(AppLocalizations.of(context)!.date_field),
                      value: 'date',
                    ),
                  ]),
              SizedBox(
                height: 15,
              ),
              selectedType == 'dropdown'
                  ? Column(
                      children: [
                        SizedBox(
                            width: 300,
                            height: 260,
                            child: ListView.builder(
                                itemCount: options.length,
                                shrinkWrap: false,
                                itemBuilder: (context, i) {
                                  return OptionEntry(
                                    controller: options[i],
                                    onDelete: () {
                                      options.removeAt(i);
                                      s(() {});
                                    },
                                  );
                                })),
                        FilledButton(
                            child:
                                Text(AppLocalizations.of(context)!.add_option),
                            onPressed: () {
                              options.add(TextEditingController());
                              s(() {});
                            }),
                      ],
                    )
                  : SizedBox.shrink()
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
                if (selectedType == 'dropdown') {
                  if (fieldNameC.text.isNotEmpty) {
                    validateOptions(fieldNameC.text, selectedType!, options);
                  } else {
                    showBar(
                        context,
                        AppLocalizations.of(context)!.field_name_required,
                        InfoBarSeverity.warning);
                  }
                } else if (selectedType == 'text' || selectedType == 'date') {
                  if (fieldNameC.text.isNotEmpty) {
                    saveTextField(fieldNameC.text, selectedType!);
                  } else {
                    showBar(
                        context,
                        AppLocalizations.of(context)!.field_name_required,
                        InfoBarSeverity.warning);
                  }
                } else {
                  showBar(
                      context,
                      AppLocalizations.of(context)!.field_type_required,
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
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
          leading: IconButton(
              icon: Icon(FluentIcons.arrow_down_right8),
              onPressed: () {
                Navigator.pushReplacement(context,
                    FluentPageRoute(builder: (context) => MainScreen()));
              })),
      content: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Card(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Spacer(),
                            Text(AppLocalizations.of(context)!
                                .registered_implants),
                            Spacer(),
                            IconButton(
                                icon: Icon(FluentIcons.add),
                                onPressed: () {
                                  showAddImplantTypeDialog(context);
                                })
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: FutureBuilder(
                              future: getImplantsTypes(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox.shrink();
                                } else if (snapshot.hasError) {
                                  return SizedBox.shrink();
                                } else if (snapshot.data!.isEmpty) {
                                  return SizedBox.shrink();
                                } else {
                                  return ListView.builder(
                                    shrinkWrap: false,
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, i) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile.selectable(
                                          onPressed: () {
                                            selectType(snapshot.data![i]['id']);
                                          },
                                          leading:
                                              Text(snapshot.data![i]['name']),
                                        ),
                                      );
                                    },
                                  );
                                }
                              }),
                        )
                      ],
                    ),
                  )),
              Expanded(
                  flex: 7,
                  child: Builder(builder: (context) {
                    if (selectedType != null) {
                      return FutureBuilder(
                          future: Provider.of<CustomFieldProvider>(context)
                              .getImplantsFields(selectedType!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox.shrink();
                            } else if (snapshot.hasError) {
                              return SizedBox.shrink();
                            } else if (snapshot.data!.isEmpty) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Spacer(),
                                      Text(AppLocalizations.of(context)!
                                          .implant_type_fields),
                                      Spacer(),
                                      FilledButton(
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .add_field),
                                          onPressed: () {
                                            showAddFieldDialog(context);
                                          }),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      BasicFlyout(
                                          warning: AppLocalizations.of(context)!
                                              .delete_type_warning,
                                          onProceed: () {
                                            deleteImplantType();
                                          },
                                          action: AppLocalizations.of(context)!
                                              .delete_type_confirmation,
                                          buttonText:
                                              AppLocalizations.of(context)!
                                                  .delete_type),
                                    ],
                                  ),
                                  Expanded(
                                      child: Center(
                                    child: Text(AppLocalizations.of(context)!
                                        .no_fields_found),
                                  ))
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Spacer(),
                                      Text(AppLocalizations.of(context)!
                                          .implant_type_fields),
                                      Spacer(),
                                      FilledButton(
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .add_field),
                                          onPressed: () {
                                            showAddFieldDialog(context);
                                          }),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      BasicFlyout(
                                          warning: AppLocalizations.of(context)!
                                              .delete_type_warning,
                                          onProceed: () {
                                            deleteImplantType();
                                          },
                                          action: AppLocalizations.of(context)!
                                              .delete_type_confirmation,
                                          buttonText:
                                              AppLocalizations.of(context)!
                                                  .delete_type)
                                    ],
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: false,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, i) {
                                        if (snapshot.data![i]['field_type'] ==
                                            'dropdown') {
                                          return ImplantFieldDropDown(
                                              typeData: snapshot.data![i]);
                                        } else if (snapshot.data![i]
                                                ['field_type'] ==
                                            'text') {
                                          return ImplantFieldText(
                                            typeData: snapshot.data![i],
                                          );
                                        } else {
                                          return ImplantFieldDate(
                                            typeData: snapshot.data![i],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }
                          });
                    } else {
                      return SizedBox.shrink();
                    }
                  })),
            ],
          ),
        ),
      ),
    );
  }
}
