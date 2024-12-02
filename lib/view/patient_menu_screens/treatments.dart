import 'package:dental_clinic/view/patient_menu_screens/general_treatments_menu.dart';
import 'package:dental_clinic/view/patient_menu_screens/treatment_tooth_menu.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../database/sqflite.dart';
import '../../shared/custom_widgets/tooth_treatment.dart';

class Treatments extends StatefulWidget {
  final int patientId;
  const Treatments({super.key, required this.patientId});

  @override
  State<Treatments> createState() => _TreatmentsState();
}

class _TreatmentsState extends State<Treatments>
    with AutomaticKeepAliveClientMixin {
  SqlDb dataHelper = SqlDb();

  int activeToothCode = 0;
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
                                  child: Button(
                                      onPressed: () {
                                        setState(() {
                                          activeToothCode = 0;
                                          pageController
                                              .jumpToPage(activeToothCode);
                                        });
                                      },
                                      child: Text(AppLocalizations.of(context)!
                                          .general_treatments)),
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
