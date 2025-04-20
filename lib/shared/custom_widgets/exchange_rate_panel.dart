import 'dart:convert';
import 'dart:io';
import 'package:dental_clinic/model/api/syrian_pound_scrapper.dart';
import 'package:http/http.dart' as http;
import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/view_model/exchange_rate_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ExchangeRatePanel extends StatefulWidget {
  const ExchangeRatePanel({super.key});

  @override
  State<ExchangeRatePanel> createState() => _ExchangeRatePanelState();
}

class _ExchangeRatePanelState extends State<ExchangeRatePanel> {
  num usdRate = 34.10;
  bool isEnabled = false;
  TextEditingController rateC = TextEditingController();
  SqlDb dataHelper = SqlDb();

  Future<void> getExchangeOnline(context) async {
    await showUploadLoadingAlert(context);

    const String apiUrl = 'https://open.er-api.com/v6/latest/USD';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        Map data = jsonDecode(response.body);
        String rateS = data['rates']['TRY'].toStringAsFixed(2);
        num rate = num.parse(rateS);
        await dataHelper
            .updateData('''UPDATE prices SET exchange = $rate WHERE id = 1''');
        usdRate = rate;
        rateC.text = rate.toStringAsFixed(2);
        setState(() {});

        showBar(context, 'تم تحديث السعر, السعر الجديد: $rate ',
            InfoBarSeverity.success);
      } else {
        showBar(context, 'خطأ', InfoBarSeverity.error);
      }
    } on SocketException catch (_) {
      Navigator.of(context).pop();
      // No internet connection or DNS error
      showBar(context, 'لا يوجد اتصال بالإنترنت', InfoBarSeverity.warning);
    } catch (e) {
      // Other errors (e.g., server errors, timeout)
      Navigator.of(context).pop();

      showBar(context, 'خطأ غير متوقع, حاول مجددا', InfoBarSeverity.error);
    }
  }

  showUploadLoadingAlert(BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return const ContentDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProgressBar(),
                SizedBox(
                  height: 20,
                ),
                Text('جاري تحديث السعر... ')
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<ExchangeRateProvider>(context, listen: false).getRate();
      usdRate = Provider.of<ExchangeRateProvider>(context, listen: false).rate;
      rateC.text = usdRate.toStringAsFixed(2);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text.rich(TextSpan(text: 'سعر صرف الدولار', children: [
          TextSpan(text: ' : '),
        ])),
        SizedBox(
            width: 70,
            child: TextBox(
              controller: rateC,
              enabled: isEnabled,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
              ],
            )),
        Text('ليرة تركي'),
        SizedBox(
          width: 20,
        ),
        !isEnabled
            ? FilledButton(
                child: Text('تعديل السعر'),
                onPressed: () {
                  setState(() {
                    isEnabled = true;
                  });
                })
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                      child: Text('حفظ'),
                      onPressed: () async {
                        if (rateC.text.isNotEmpty) {
                          double value = double.parse(rateC.text);
                          await Provider.of<ExchangeRateProvider>(context,
                                  listen: false)
                              .setRate(value);
                          await Provider.of<ExchangeRateProvider>(context,
                                  listen: false)
                              .getRate();
                          setState(() {
                            usdRate = value;
                            isEnabled = false;
                          });
                        } else {
                          showBar(context, 'ادخل سعر الصرف',
                              InfoBarSeverity.warning);
                        }
                      }),
                  SizedBox(
                    width: 10,
                  ),
                  Button(
                      child: Text('إلغاء'),
                      onPressed: () {
                        setState(() {
                          isEnabled = false;
                          rateC.text = usdRate.toStringAsFixed(2);
                        });
                      })
                ],
              ),
        SizedBox(
          width: 20,
        ),
        FilledButton(
            child: Text('تحديث السعر من الانترنت'),
            onPressed: () {
              getExchangeOnline(context);
            })
      ],
    );
  }
}

class ExchangeRateSyrianPanel extends StatefulWidget {
  const ExchangeRateSyrianPanel({super.key});

  @override
  State<ExchangeRateSyrianPanel> createState() =>
      _ExchangeRateSyrianPanelState();
}

class _ExchangeRateSyrianPanelState extends State<ExchangeRateSyrianPanel> {
  num usdRate = 10900.00;
  bool isEnabled = false;
  TextEditingController rateC = TextEditingController();
  SqlDb dataHelper = SqlDb();

  Future<void> getExchangeOnline(context) async {
    await showUploadLoadingAlert(context);

    try {
      double? rate1 = await readHtml();

      if (rate1 != null) {
        Navigator.of(context).pop();
        num rate = rate1;
        await dataHelper.updateData(
            '''UPDATE prices SET syrian_pound_exchange = $rate WHERE id = 1''');
        usdRate = rate;
        rateC.text = rate.toStringAsFixed(2);
        setState(() {});

        showBar(context, 'تم تحديث السعر, السعر الجديد: $rate ',
            InfoBarSeverity.success);
      } else {
        showBar(context, 'خطأ', InfoBarSeverity.error);
      }
    } on SocketException catch (_) {
      Navigator.of(context).pop();
      // No internet connection or DNS error
      showBar(context, 'لا يوجد اتصال بالإنترنت', InfoBarSeverity.warning);
    } catch (e) {
      // Other errors (e.g., server errors, timeout)
      Navigator.of(context).pop();

      showBar(context, 'خطأ غير متوقع, حاول مجددا', InfoBarSeverity.error);
    }
  }

  showUploadLoadingAlert(BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return const ContentDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProgressBar(),
                SizedBox(
                  height: 20,
                ),
                Text('جاري تحديث السعر... ')
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<ExchangeRateProvider>(context, listen: false)
          .getSpRate();
      usdRate =
          Provider.of<ExchangeRateProvider>(context, listen: false).spRate;
      rateC.text = usdRate.toStringAsFixed(2);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text.rich(TextSpan(text: 'سعر صرف الدولار', children: [
          TextSpan(text: ' : '),
        ])),
        SizedBox(
            width: 110,
            child: TextBox(
              controller: rateC,
              enabled: isEnabled,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
              ],
            )),
        Text('ليرة سورية'),
        SizedBox(
          width: 20,
        ),
        !isEnabled
            ? FilledButton(
                child: Text('تعديل السعر'),
                onPressed: () {
                  setState(() {
                    isEnabled = true;
                  });
                })
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                      child: Text('حفظ'),
                      onPressed: () async {
                        if (rateC.text.isNotEmpty) {
                          double value = double.parse(rateC.text);
                          await Provider.of<ExchangeRateProvider>(context,
                                  listen: false)
                              .setSpRate(value);
                          await Provider.of<ExchangeRateProvider>(context,
                                  listen: false)
                              .getSpRate();
                          setState(() {
                            usdRate = value;
                            isEnabled = false;
                          });
                        } else {
                          showBar(context, 'ادخل سعر الصرف',
                              InfoBarSeverity.warning);
                        }
                      }),
                  SizedBox(
                    width: 10,
                  ),
                  Button(
                      child: Text('إلغاء'),
                      onPressed: () {
                        setState(() {
                          isEnabled = false;
                          rateC.text = usdRate.toStringAsFixed(2);
                        });
                      })
                ],
              ),
        SizedBox(
          width: 20,
        ),
        FilledButton(
            child: Text('تحديث السعر من الانترنت'),
            onPressed: () {
              getExchangeOnline(context);
            })
      ],
    );
  }
}
