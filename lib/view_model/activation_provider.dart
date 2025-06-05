import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dental_clinic/model/encryption/windows_encryption.dart';
import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/public_methods/device_info.dart';
import 'package:dental_clinic/view/initializer.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'navigationService.dart';

class ActivationProvider extends ChangeNotifier {
  String activationDialogFlag = 'n';

  void toggleActFlag(String value) {
    activationDialogFlag = value;
    notifyListeners();
  }

  Future<Map?> rawPostRequest(Map payloadBody) async {
    final url = Uri.https(
        'puiqb7jmh5wbbcydm6dukxu6aa0nxcbt.lambda-url.us-west-2.on.aws'); // fake API for testing

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payloadBody),
      );
      return {"status": response.statusCode, "body": response.body};
    } catch (e) {
      rethrow;
    }
  }

  Future<void> activate(BuildContext context, String key) async {
    showAuthDialog(context);

    String device_name = await getDeviceName();
    Map payload = {"type": "activate", "key": key, "device_name": device_name};
    try {
      Map? response = await rawPostRequest(payload);
      if (response != null) {
        print(response);
        if (response['status'] == 200) {
          Map body = jsonDecode(response["body"]);
          String token = body["token"];
          if (Platform.isWindows) {
            await WindowsSecureStorage.saveToken(token);
          } else if (Platform.isMacOS) {
            final secureStorage = FlutterSecureStorage();
            await secureStorage.write(key: 'd1t1_auth', value: token);
          }

          // navigateTo(context, Initializer());
          toggleActFlag('valid');
        } else {
          toggleActFlag('invalid');
        }
      }
    } on SocketException catch (e) {
      print(e);
      safePop(context);
      showBarWithC(context, 'لا يوجد اتصال بالانترنت');
    } catch (e) {
      print(e);
      safePop(context);
      showBarWithC(context, 'حاول مجددا');
    }
  }

  Future<void> loginOptional(BuildContext context, String key) async {
    String device_name = await getDeviceName();
    Map payload = {"type": "login", "key": key, "device_name": device_name};
    try {
      Map? response = await rawPostRequest(payload);
      if (response != null) {
        print(response);
        if (response['status'] == 200) {
          Map body = jsonDecode(response["body"]);
          String flag = body["response"];
          if (flag == 'forget') {
            if (Platform.isWindows) {
              await WindowsSecureStorage.deleteToken();
            } else if (Platform.isMacOS) {
              final secureStorage = FlutterSecureStorage();
              await secureStorage.delete(key: 'd1t1_auth');
            }

            print('deleted forever');
          }
        } else {}
      }
    } on SocketException catch (e) {
    } catch (e) {}
  }

  Future<void> navigateTo(BuildContext context, Widget route) async {
    Navigator.of(context).pushReplacement(FluentPageRoute(builder: (context) {
      return route;
    }));
  }

  Future<void> showBarWithC(BuildContext context, String m) async {
    showBar(context, m, InfoBarSeverity.warning);
  }

  void showAuthDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => Consumer<ActivationProvider>(
        builder: (context, v, child) {
          return ContentDialog(
            constraints: BoxConstraints(
                minWidth: 300, minHeight: 400, maxWidth: 300, maxHeight: 500),
            content: Column(
              children: [
                Consumer<ActivationProvider>(builder: (context, value, child) {
                  if (value.activationDialogFlag == 'n') {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                            repeat: true,
                            animate: true,
                            'assets/lottie/loading.json'),
                      ],
                    );
                  } else if (value.activationDialogFlag == 'valid') {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                            repeat: true,
                            animate: true,
                            'assets/lottie/success_animation.json'),
                        Text('تم تفعيل البرنامج بنجاح'),
                      ],
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                            repeat: true,
                            animate: true,
                            'assets/lottie/fail.json'),
                        Text('مفتاح التفعيل غير صالح'),
                      ],
                    );
                  }
                }),
              ],
            ),
            actions: v.activationDialogFlag == 'valid'
                ? [
                    Button(
                        child: Text('تم'),
                        onPressed: () {
                          navigateTo(context, Initializer());
                        })
                  ]
                : v.activationDialogFlag == 'invalid'
                    ? [
                        Button(
                            child: Text('إغلاق'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            })
                      ]
                    : [],
          );
        },
      ),
    );
    //reset
    toggleActFlag('n');
  }

  void safePop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}
