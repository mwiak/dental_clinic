import 'package:dental_clinic/shared/custom_widgets/pregnancy_session_item.dart';
import 'package:dental_clinic/view_model/pregnancy_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../shared/custom_widgets/date_pickers.dart';

class PregnancyPage extends StatefulWidget {
  final int id;
  final int patientId;
  final Map data;
  const PregnancyPage(
      {super.key,
      required this.id,
      required this.patientId,
      required this.data});

  @override
  State<PregnancyPage> createState() => _PregnancyPageState();
}

class _PregnancyPageState extends State<PregnancyPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> validateInput(TextEditingController dateC) async {
    if (dateC.text.isNotEmpty) {
      Provider.of<PregnancyProvider>(context, listen: false)
          .addNewPregnancySession(
              widget.data['patient_id'], dateC.text, widget.data['id']);
    }
  }

  Future<void> showAddPregnancySessionDialog(BuildContext context) async {
    TextEditingController startDateC = TextEditingController();
    TextEditingController endDateC = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        constraints: BoxConstraints(maxWidth: 300, maxHeight: 300),
        title: Text('إضافة حمل جديد'),
        content: Column(
          children: [
            DatePickerBasic(
              value: startDateC,
              label: 'تاريخ الجلسة',
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
              await validateInput(startDateC);
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
    Provider.of<PregnancyProvider>(context, listen: false)
        .getPregnancySessions(widget.id);
    return NavigationView(
      appBar: NavigationAppBar(),
      content: Center(
        child: Column(
          children: [
            CommandBarCard(
                child: CommandBar(primaryItems: [
              CommandBarButton(
                  onPressed: () {
                    showAddPregnancySessionDialog(context);
                  },
                  label: Text('إضافة جلسة متابعة')),
              CommandBarSeparator(thickness: 20, color: Colors.transparent),
              CommandBarBuilderItem(
                  builder: (context, d, m) {
                    return Text('data');
                  },
                  wrappedItem: CommandBarSeparator())
            ])),
            Expanded(
              child: Consumer<PregnancyProvider>(
                builder: (context, value, child) {
                  return ListView.builder(
                      itemCount: value.sessions.length,
                      itemBuilder: (context, i) {
                        return PregnancySessionItem(
                          data: value.sessions[i],
                          i: i + 1,
                        );
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
