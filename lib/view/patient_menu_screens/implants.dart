import 'package:dental_clinic/shared/custom_widgets/tooth_implants.dart';
import 'package:dental_clinic/view/patient_menu_screens/implants_tooth_menu.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../../database/sqflite.dart';

class Implants extends StatefulWidget {
  final int patientId;
  const Implants({super.key, required this.patientId});

  @override
  State<Implants> createState() => _ImplantsState();
}

class _ImplantsState extends State<Implants>
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
                                    width: 5,
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
