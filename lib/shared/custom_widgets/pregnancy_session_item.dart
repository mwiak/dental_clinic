import 'package:dental_clinic/shared/custom_widgets/editor_text_box.dart';
import 'package:dental_clinic/shared/custom_widgets/editor_text_box_exp.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../view_model/pregnancy_provider.dart';
import '../public_methods/glassy_bar.dart';
import 'date_pickers.dart';

class PregnancySessionItem extends StatefulWidget {
  final Map data;
  final int i;

  const PregnancySessionItem({super.key, required this.data, required this.i});

  @override
  State<PregnancySessionItem> createState() => _PregnancySessionItemState();
}

class _PregnancySessionItemState extends State<PregnancySessionItem> {
  TextEditingController echoC = TextEditingController();
  TextEditingController symptomsC = TextEditingController();
  TextEditingController notesC = TextEditingController();

  bool isEditing = false;

  Widget generateEditingButtons() {
    if (!isEditing) {
      return Button(
          child: Text('تعديل'),
          onPressed: () {
            setState(() {
              isEditing = true;
            });
          });
    } else {
      return Row(
        children: [
          Button(
              child: Text('حفظ'),
              onPressed: () {
                setState(() {
                  isEditing = false;
                });
              }),
          SizedBox(
            width: 30,
          ),
          Button(
              child: Text('عدم الحفظ'),
              onPressed: () {
                setState(() {
                  isEditing = false;
                });
              })
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expander(
      leading: Card(
          child: Text(
        widget.i.toString(),
      )),
      trailing: Text('توسعة'),
      header: Text(
        widget.data['date'],
      ),
      content: SizedBox(
        height: 250,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 550,
                    child: EditorTextBoxExp(
                      controller: echoC,
                      label: 'تقرير الإيكو',
                      isEditing: isEditing,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  SizedBox(
                    width: 200,
                    child: EditorTextBoxExp(
                        controller: symptomsC,
                        label: 'أعراض محتملة',
                        isEditing: isEditing),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  SizedBox(
                    width: 200,
                    child: EditorTextBoxExp(
                        controller: notesC,
                        label: 'ملاحظات',
                        isEditing: isEditing),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 50,
                    child: IconButton(
                        icon: Icon(FluentIcons.delete), onPressed: () {}),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Button(
                      child: Row(
                        children: [
                          Text('رفع صورة الإيكو'),
                          Icon(FluentIcons.upload),
                        ],
                      ),
                      onPressed: () {}),
                  Spacer(),
                  generateEditingButtons()
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
