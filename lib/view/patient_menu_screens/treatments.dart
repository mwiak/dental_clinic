import 'package:dental_clinic/view/patient_menu_screens/general_treatments_menu.dart';
import 'package:dental_clinic/view/patient_menu_screens/treatment_tooth_menu.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../database/sqflite.dart';
import '../../shared/custom_widgets/tooth_treatment.dart';
import 'multiple_teeth_treatment.dart';
import 'multiple_tooth_treatment_menu.dart';

class Treatments extends StatefulWidget {
  final int patientId;
  const Treatments({super.key, required this.patientId});

  @override
  State<Treatments> createState() => _TreatmentsState();
}

class _TreatmentsState extends State<Treatments>
    with AutomaticKeepAliveClientMixin {
  SqlDb dataHelper = SqlDb();
  final GlobalKey<MultipleToothTreatmentMenuState> childKey = GlobalKey();
  int activeToothCode = 0;
  PageController pageController = PageController();
  bool isGeneral = false;
  List selectedCodes = [];
  List getSelectedTeethCodes() {
    return [];
  }

  void onPressed(int value, bool flag) {
    if (flag) {
      selectedCodes.add(value);
    } else {
      selectedCodes.remove(value);
    }
  }

  void updateActiveToothCode(int code) {
    setState(() {
      activeToothCode = code - 10;
      pageController.jumpToPage(
        activeToothCode,
      );
    });
  }

  List<Widget> getActiveToothMenu() {
    List<Widget> items = [
      GeneralTreatmentsMenu(
        patientId: widget.patientId,
      )
    ];
    for (int x = 11; x < 49; x++) {
      items.add(TreatmentToothMenu(
        patientId: widget.patientId,
        toothCode: x,
        dataHelper: dataHelper,
      ));
    }
    return items;
  }

  void showAddMultipleTreatmentDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(
              minWidth: 200, minHeight: 200, maxHeight: 400, maxWidth: 900),
          title: Text('علاج عدة أسنان'),
          content: ListView(children: [
            MultipleTeethTreatment(
              selectedCodes: selectedCodes,
              isGeneral: false,
              onIsGeneralChanged: (newValue) {
                isGeneral = newValue;
              },
              description:
                  'اختر الأسنان, سيتم إضافة علاج مشترك للأسنان التي يتم اختيارها',
            )
          ]),
          actions: [
            Button(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.pop(context, 'User deleted file');
                selectedCodes = [];
                // Delete file here
              },
            ),
            FilledButton(
              child: Text('التالي'),
              onPressed: () {
                Navigator.pop(context, 'User deleted file');
                showAddMultipleTreatmentMenu(context, selectedCodes, isGeneral);
                selectedCodes = [];
              },
            ),
          ],
        );
      }),
    );
  }

  void showAddMultipleTreatmentMenu(
      BuildContext context, List codes, bool isGeneral) async {
    print(isGeneral);
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(
              minWidth: 200, minHeight: 200, maxHeight: 600, maxWidth: 500),
          title: Text(AppLocalizations.of(context)!.add_treatment),
          content: MultipleToothTreatmentMenu(
            key: childKey,
            patientId: widget.patientId,
            codes: codes,
            dataHelper: dataHelper,
            isGeneral: isGeneral,
          ),
          actions: [
            Button(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.pop(context);
                selectedCodes = [];
                // Delete file here
              },
            ),
            FilledButton(
              child: Text('add'),
              onPressed: () async {
                childKey.currentState!.validateRequiredFields();
              },
            ),
          ],
        );
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                    child: PageView(
                  controller: pageController,
                  children: getActiveToothMenu(),
                )),
              )),
          Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Center(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                textDirection: TextDirection.ltr,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ToothTreatments(
                                      code: 18,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 17,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 16,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 15,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 14,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 13,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 12,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 11,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  ToothTreatments(
                                      code: 21,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 22,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 23,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 24,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 25,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 26,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 27,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 28,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                ],
                              ),
                              SizedBox(
                                height: 150,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Button(
                                          onPressed: () {
                                            setState(() {
                                              activeToothCode = 0;
                                              pageController
                                                  .jumpToPage(activeToothCode);
                                            });
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .general_treatments)),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Button(
                                          onPressed: () {
                                            showAddMultipleTreatmentDialog(
                                                context);
                                          },
                                          child: Text('علاج عدة أسنان')),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                textDirection: TextDirection.ltr,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ToothTreatments(
                                      code: 48,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 47,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 46,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 45,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 44,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 43,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 42,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 41,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ToothTreatments(
                                      code: 31,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 32,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 33,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 34,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 35,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 36,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 37,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothTreatments(
                                      code: 38,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
