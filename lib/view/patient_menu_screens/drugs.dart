import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/custom_widgets/flyout.dart';
import 'package:dental_clinic/shared/custom_widgets/text_boxes.dart';
import 'package:dental_clinic/view/main_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/patient_menu_model.dart';

class Drugs extends StatefulWidget {
  final int patientId;

  const Drugs({super.key, required this.patientId});

  @override
  State<Drugs> createState() => _DrugsState();
}

class _DrugsState extends State<Drugs> with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Text('صفحة للوصفات الطبية'),
    );
  }
}
