import 'package:dental_clinic/shared/custom_widgets/large_field_box.dart';
import 'package:dental_clinic/shared/public_methods/datetime_methods.dart';
import 'package:dental_clinic/shared/public_methods/navigation.dart';
import 'package:dental_clinic/view/patient_menu_screens/pregnancy_page.dart';
import 'package:dental_clinic/view_model/pregnancy_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../public_methods/glassy_bar.dart';
import 'auto_suggest_boxes.dart';
import 'date_pickers.dart';
import 'flyout.dart';

class PregnancyCard extends StatefulWidget {
  final Map data;
  const PregnancyCard({super.key, required this.data});

  @override
  State<PregnancyCard> createState() => _PregnancyCardState();
}

class _PregnancyCardState extends State<PregnancyCard> {
  final FlyoutController deleteController = FlyoutController();

  String calculateBirthTime() {
    DateTime? startDate = DateTime.now();
    DateTime? endDate = stringToDate(widget.data['expected_birth_date']);
    Duration? periodToBirth = endDate?.difference(startDate!);
    int timeInDays = periodToBirth!.inDays;
    int timeInMonths = timeInDays ~/ 30;
    int timeInRDays = timeInDays % 30;

    if (timeInDays < 0) {
      return 'مضى $timeInRDays على وقت الولادة المتوقع';
    } else {
      if (timeInMonths > 0 && timeInRDays > 0) {
        return "تبقى $timeInMonths شهر و $timeInRDays يوم";
      } else if (timeInMonths == 0 && timeInRDays > 0) {
        return 'تبقى $timeInRDays يوم';
      } else if (timeInMonths > 0 && timeInRDays == 0) {
        return 'تبقى $timeInMonths شهرا';
      } else {
        return '';
      }
    }
  }

  String parseStatus() {
    String status = widget.data['status'] ?? 'غير محدد';
    if (status == 'ongoing') {
      return 'مستمر';
    } else {
      return status;
    }
  }

  //menus
  Future<void> showCompletePregnancyDialog(BuildContext context) async {
    int currentPage = 0;
    PageController pageController = PageController();
    TextEditingController endStatusC = TextEditingController();
    TextEditingController completeDateC = TextEditingController();
    TextEditingController summaryC = TextEditingController();

    Future<void> validateFields() async {
      if (endStatusC.text.isNotEmpty && completeDateC.text.isNotEmpty) {
        // await Provider.of<PregnancyProvider>(context, listen: false)
        //     .completePregnancy(widget.data['id'], widget.data['patient_id'],
        //         endStatusC.text.trim(), completeDateC.text.trim());

        //next
      } else {}
    }

    await showDialog(
      context: context,
      builder: (context) {
        ValueNotifier<int> currentPage = ValueNotifier(0);

        return ContentDialog(
          constraints: BoxConstraints(
              minWidth: 200, minHeight: 300, maxHeight: 600, maxWidth: 400),
          title: Text('إتمام الحمل'),
          content: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(), // منع السحب
            children: [
              // صفحة 1
              Column(
                children: [
                  AutoSuggestBoxesForPregnancyComplete(
                    choices: ['إجهاض', 'قيصرية', 'ولادة طبيعية'],
                    valueC: endStatusC,
                  ),
                  const SizedBox(height: 10),
                  DatePickerBasic(
                    value: completeDateC,
                    label: 'تاريخ نهاية الحمل',
                    requiredSymbol: '*',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  LargeFieldBox(
                      controller: summaryC, label: 'تقرير نهاية الحمل'),
                ],
              ),
              // صفحة 2
              Column(
                children: [
                  Text('هل أنت متأكد من إتمام الحمل؟'),
                  Text('البيانات: ${endStatusC.text} - ${completeDateC.text}'),
                ],
              ),
            ],
          ),
          actions: [
            ValueListenableBuilder<int>(
              valueListenable: currentPage,
              builder: (context, page, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Button(
                      child: Text(page == 0
                          ? AppLocalizations.of(context)!.cancel
                          : 'عودة'),
                      onPressed: () {
                        if (page == 0) {
                          Navigator.pop(context);
                        } else {
                          pageController.animateToPage(0,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeInOut);
                          currentPage.value = 0;
                        }
                      },
                    ),
                    Spacer(),
                    FilledButton(
                      child: Text(page == 0 ? 'التالي' : 'إكمال'),
                      onPressed: () async {
                        if (page == 0) {
                          await validateFields();
                          pageController.animateToPage(1,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                          currentPage.value = 1;
                        } else {
                          await validateFields();
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );

    endStatusC.dispose();
    completeDateC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: SizedBox(
        width: 500,
        child: Card(
          child: Row(
            children: [
              Expanded(
                  child: SizedBox(
                      height: 50,
                      child: Column(
                        children: [
                          Text('تاريخ كشف الحمل'),
                          Text(widget.data['start_date']),
                        ],
                      ))),
              Expanded(
                  child: SizedBox(
                      height: 50,
                      child: Column(
                        children: [
                          Text('تاريخ الولادة المتوقع'),
                          Text(widget.data['expected_birth_date']),
                        ],
                      ))),
              Expanded(
                  child: SizedBox(
                      height: 50,
                      child: Column(
                        children: [
                          Text('المدة المتبقية للولادة'),
                          Text(calculateBirthTime()),
                        ],
                      ))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SizedBox(
                    height: 30,
                    child: FilledButton(
                      child: Text('الجلسات'),
                      onPressed: () {
                        goToPushOnly(
                            context,
                            PregnancyPage(
                                id: widget.data['id'],
                                patientId: widget.data['patient_id'],
                                data: widget.data));
                      },
                    )),
              ),
              Expanded(
                  child: DropDownButton(
                title: Text('حالة الحمل: ${parseStatus()}'),
                items: [
                  MenuFlyoutItem(
                      text: Text('إتمام الحمل'),
                      onPressed: () async {
                        showCompletePregnancyDialog(context);
                      }),
                  const MenuFlyoutSeparator(),
                  MenuFlyoutItem(
                      text: BasicFlyout(
                          warning: AppLocalizations.of(context)!.delete_warning,
                          onProceed: () {
                            safePop(context);
                            Provider.of<PregnancyProvider>(context,
                                    listen: false)
                                .deletePregnancy(widget.data['id'],
                                    widget.data['patient_id']);
                          },
                          action: AppLocalizations.of(context)!.delete_confirm,
                          buttonText:
                              AppLocalizations.of(context)!.delete_patient),
                      onPressed: () async {}),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
