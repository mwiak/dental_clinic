import 'package:dental_clinic/shared/custom_widgets/tooth_implants.dart';
import 'package:dental_clinic/view/patient_menu_screens/implants_tooth_menu.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../../database/sqflite.dart';
import 'multiple_teeth_implants_menu.dart';
import 'multiple_teeth_treatment.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Implants extends StatefulWidget {
  final int patientId;
  const Implants({super.key, required this.patientId});

  @override
  State<Implants> createState() => _ImplantsState();
}

class _ImplantsState extends State<Implants>
    with AutomaticKeepAliveClientMixin {
  SqlDb dataHelper = SqlDb();
  List selectedCodes = [];
  int activeToothCode = 0;
  final GlobalKey<MultipleTeethImplantMenuState> childKey = GlobalKey();
  PageController pageController = PageController();

  void updateActiveToothCode(int code) {
    setState(() {
      activeToothCode = code - 10;
      pageController.jumpToPage(
        activeToothCode,
      );
    });
  }

  List<Widget> getActiveToothMenu() {
    List<Widget> items = [SizedBox.shrink()];
    for (int x = 11; x < 49; x++) {
      items.add(ImplantsToothMenu(
        patientId: widget.patientId,
        toothCode: x,
        dataHelper: dataHelper,
      ));
    }
    return items;
  }

  void showAddMultipleImplantDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(
              minWidth: 200, minHeight: 200, maxHeight: 400, maxWidth: 900),
          title: Text('زراعة عدة أسنان'),
          content: ListView(children: [
            MultipleTeethTreatment(
              selectedCodes: selectedCodes,
              isGeneral: false,
              onIsGeneralChanged: (newValue) {},
              description:
                  'اختر الأسنان, سيتم إضافة زرعة مشتركة للأسنان التي يتم اختيارها',
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
                showAddMultipleImplantMenu(context, selectedCodes);
                selectedCodes = [];
              },
            ),
          ],
        );
      }),
    );
  }

  void showAddMultipleImplantMenu(BuildContext context, List codes) async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: const BoxConstraints(
              minWidth: 200, minHeight: 200, maxHeight: 600, maxWidth: 500),
          title: Text(AppLocalizations.of(context)!.add_treatment),
          content: MultipleTeethImplantMenu(
            key: childKey,
            patientId: widget.patientId,
            codes: codes,
            dataHelper: dataHelper,
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
              child: Text('إضافة'),
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
                  children: getActiveToothMenu(),
                  controller: pageController,
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
                                  ToothImplants(
                                      code: 18,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 17,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 16,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 15,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 14,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 13,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 12,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 11,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ToothImplants(
                                      code: 21,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 22,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 23,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 24,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 25,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 26,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 27,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
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
                                            showAddMultipleImplantDialog(
                                                context);
                                          },
                                          child: Text('زراعة عدة أسنان')),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                textDirection: TextDirection.ltr,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ToothImplants(
                                      code: 48,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 47,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 46,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 45,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 44,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 43,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 42,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 41,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ToothImplants(
                                      code: 31,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 32,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 33,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 34,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 35,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 36,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
                                      code: 37,
                                      onTap: updateActiveToothCode,
                                      patientId: widget.patientId),
                                  ToothImplants(
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
