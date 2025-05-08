import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/theme.dart';
import 'package:dental_clinic/view/initializer.dart';
import 'package:dental_clinic/view_model/activation_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../view_model/user_provider.dart';
import 'main_screen.dart';

class ActivationPage extends StatefulWidget {
  const ActivationPage({super.key});

  @override
  State<ActivationPage> createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  TextEditingController keyC = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  void dispose() {
    super.dispose();
    keyC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Center(
        child: Container(
          height: 300,
          width: 300,
          child: Column(
            children: [
              Text('مرحبا, أدخل مفتاح التفعيل للبدء'), //
              SizedBox(
                height: 5,
              ),
              TextBox(
                controller: keyC,
                placeholder: 'مفتاح التفعيل',
              ),
              SizedBox(
                height: 5,
              ),

              SizedBox(
                height: 5,
              ),

              Button(
                  child: Text("متابعة"),
                  onPressed: () async {
                    if (keyC.text.isNotEmpty) {
                      Provider.of<ActivationProvider>(context, listen: false)
                          .activate(context, keyC.text.trim());
                    }
                  }),
              SizedBox(
                height: 60,
              ),
              Card(
                child: SizedBox(
                  width: 360,
                  child: Column(
                    children: [
                      Text('خدمة العملاء'),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 300,
                        child: Row(
                          textDirection: TextDirection.ltr,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                                width: 40, height: 40, 'assets/whatsup.png'),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                                textDirection: TextDirection.ltr,
                                '+963959459372')
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
