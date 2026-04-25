import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/custom_widgets/flyout.dart';
import 'package:dental_clinic/shared/custom_widgets/pregnancy_card.dart';
import 'package:dental_clinic/shared/custom_widgets/text_boxes.dart';
import 'package:dental_clinic/shared/public_methods/glassy_bar.dart';
import 'package:dental_clinic/view/main_screen.dart';
import 'package:dental_clinic/view_model/pregnancy_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../model/patient_menu_model.dart';
import '../../shared/custom_widgets/date_pickers.dart';

class Pregnancy extends StatefulWidget {
  final int patientId;

  const Pregnancy({super.key, required this.patientId});

  @override
  State<Pregnancy> createState() => _PregnancyState();
}

class _PregnancyState extends State<Pregnancy>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  Future<void> showAddPregnancyDialog(BuildContext context) async {
    TextEditingController startDateC = TextEditingController();
    TextEditingController endDateC = TextEditingController();

    Future<void> validateFields() async {
      if (startDateC.text.isNotEmpty && endDateC.text.isNotEmpty) {
        await Provider.of<PregnancyProvider>(context, listen: false)
            .addNewPregnancy(widget.patientId, startDateC.text, endDateC.text);
        showSuccessBar(context);
      } else {
        showCustomBar(context, 'sdhaskjdasd', InfoBarSeverity.success);
      }
    }

    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        constraints: BoxConstraints(maxWidth: 300, maxHeight: 300),
        title: Text('إضافة حمل جديد'),
        content: Column(
          children: [
            DatePickerBasic(
              value: startDateC,
              label: 'تاريخ كشف الحمل',
              requiredSymbol: '*',
            ),
            SizedBox(
              height: 5,
            ),
            DatePickerBasic(
              value: endDateC,
              label: 'تاريخ الولادة المتوقع',
              requiredSymbol: '*',
            ),
            SizedBox(
              height: 5,
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
            onPressed: () async {
              await validateFields();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );

    startDateC.dispose();
    endDateC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Provider.of<PregnancyProvider>(context, listen: false)
        .getAllPregnancies(widget.patientId);
    return Center(
      child: Column(
        children: [
          CommandBar(
            overflowBehavior: CommandBarOverflowBehavior.noWrap,
            primaryItems: [
              CommandBarBuilderItem(
                builder: (context, mode, w) => Tooltip(
                  message: 'حمل جديد',
                  child: w,
                ),
                wrappedItem: CommandBarButton(
                  icon: const Icon(FluentIcons.add),
                  label: Text('إضافة حمل جديد'),
                  onPressed: () {
                    showAddPregnancyDialog(context);
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Consumer<PregnancyProvider>(builder: (context, value, chile) {
            return Expanded(
              child: ListView.builder(
                  itemCount: value.pregnancies.length,
                  itemBuilder: (context, i) {
                    return PregnancyCard(
                      data: value.pregnancies[i],
                    );
                  }),
            );
          })
        ],
      ),
    );
  }
}
