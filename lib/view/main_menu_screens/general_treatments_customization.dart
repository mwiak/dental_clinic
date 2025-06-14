import 'package:dental_clinic/database/sqflite.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../shared/custom_widgets/flyout.dart';

import '../main_screen.dart';

import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/custom_widgets/flyout.dart';
import 'package:dental_clinic/shared/custom_widgets/option_entry.dart';
import 'package:dental_clinic/view/main_screen.dart';
import 'package:dental_clinic/shared/custom_widgets/treatment_type_custom.dart';
import 'package:dental_clinic/view_model/custome_field_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../shared/custom_widgets/text_boxes.dart';

class GeneralTreatmentsCustomization extends StatefulWidget {
  const GeneralTreatmentsCustomization({super.key});

  @override
  State<GeneralTreatmentsCustomization> createState() =>
      _GeneralTreatmentsCustomizationState();
}

class _GeneralTreatmentsCustomizationState
    extends State<GeneralTreatmentsCustomization> {
  SqlDb dataHelper = SqlDb();

  Future<List> getTreatmentsTypes() async {
    List data = await dataHelper
        .readData(''' SELECT * FROM general_treatments_types''');
    return data;
  }

  Future<void> addNewTreatmentType(String name) async {
    await dataHelper.insertData(
        '''INSERT INTO general_treatments_types (type) VALUES ('$name') ''');
  }

  void validateAddTreatment(String name) async {
    if (name != '') {
      addNewTreatmentType(name);
      Navigator.of(context).pop();
      setState(() {});
    } else {
      showBar(context, AppLocalizations.of(context)!.title_required,
          InfoBarSeverity.warning);
    }
  }

  Future<void> deleteTreatmentType(int id) async {
    await dataHelper
        .deleteData(''' DELETE FROM general_treatments_types WHERE id = $id''');

    setState(() {});
  }

  void showAddTreatmentTypeDialog(BuildContext context) async {
    TextEditingController typeC = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(maxHeight: 400, maxWidth: 300),
          title: Text(AppLocalizations.of(context)!.add_general_treatment_type),
          content: Column(
            children: [
              InputText(
                  controller: typeC,
                  label: AppLocalizations.of(context)!.treatment_type_name),
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
                validateAddTreatment(typeC.text);
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
                Navigator.pushReplacement(
                    context,
                    FluentPageRoute(
                        builder: (context) => MainScreen(
                              selectedIndex: 5,
                            )));
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
                                .registered_general_treatments),
                            Spacer(),
                            IconButton(
                                icon: Icon(FluentIcons.add),
                                onPressed: () {
                                  showAddTreatmentTypeDialog(context);
                                })
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: FutureBuilder(
                              future: getTreatmentsTypes(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox.shrink();
                                } else if (snapshot.hasError) {
                                  return SizedBox.shrink();
                                } else if (snapshot.data!.isEmpty) {
                                  return Text(
                                      AppLocalizations.of(context)!.no_data);
                                } else {
                                  return ListView.builder(
                                    shrinkWrap: false,
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, i) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          trailing: BasicFlyout(
                                              warning:
                                                  AppLocalizations.of(context)!
                                                      .generic_warning,
                                              onProceed: () {
                                                deleteTreatmentType(
                                                    snapshot.data![i]['id']);
                                              },
                                              action: AppLocalizations.of(
                                                      context)!
                                                  .generic_delete_confirmation,
                                              buttonText:
                                                  AppLocalizations.of(context)!
                                                      .delete_type),
                                          leading:
                                              Text(snapshot.data![i]['type']),
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
            ],
          ),
        ),
      ),
    );
  }
}
