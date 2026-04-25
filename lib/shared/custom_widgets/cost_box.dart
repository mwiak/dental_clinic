import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../database/sqflite.dart';

class CostBox extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? requiredSign;
  const CostBox(
      {super.key,
      required this.label,
      required this.controller,
      this.requiredSign});

  @override
  State<CostBox> createState() => _CostBoxState();
}

class _CostBoxState extends State<CostBox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label + '*'),
        SizedBox(
          height: 7,
        ),
        SizedBox(
          width: 200,
          child: Row(
            children: [
              Expanded(
                child: TextBox(
                  controller: widget.controller,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                  ],
                  // decoration: BoxDecoration(
                  //   color: FluentTheme.of(context).cardColor,
                  //   border: Border.all(
                  //     color: FluentTheme.of(context)
                  //         .inactiveColor, // Unfocused border color
                  //     width: 1.0, // Set border width for unfocused state
                  //   ),
                  //   borderRadius: BorderRadius.circular(
                  //       4.0), // Optional: Customize corner radius
                  // ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text('  \$')
            ],
          ),
        )
      ],
    );
  }
}

class PriceFieldE extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  const PriceFieldE({super.key, required this.label, required this.controller});

  @override
  State<PriceFieldE> createState() => _PriceFieldEState();
}

class _PriceFieldEState extends State<PriceFieldE> {
  String currencySymbol = "\$";
  String currency = 'دولار';
  bool isTr = false;
  num exchangeRate = 34.20;
  num exchangeSpRate = 10900.00;
  TextEditingController trC = TextEditingController();
  SqlDb dataHelper = SqlDb();

  showModifyPriceAlert(BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return ContentDialog(
            constraints: const BoxConstraints(maxHeight: 300, maxWidth: 700),
            content: Card(
              child: SizedBox(
                width: 700,
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.usd_price),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Button(
                  child: Text('إغلاق'),
                  onPressed: () async {
                    await getRateFromDB();
                    Navigator.of(context).pop();
                    setState(() {});
                  })
            ],
          );
        });
  }

  showModifyPriceSpAlert(BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return ContentDialog(
            constraints: const BoxConstraints(maxHeight: 300, maxWidth: 700),
            content: Card(
              child: SizedBox(
                width: 700,
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.usd_price),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Button(
                  child: Text('إغلاق'),
                  onPressed: () async {
                    await getRateFromDB();
                    Navigator.of(context).pop();
                    setState(() {});
                  })
            ],
          );
        });
  }

  Future<void> getRateFromDB() async {
    List data =
        await dataHelper.readData('''SELECT * FROM prices WHERE id = 1''');
    exchangeRate = data[0]['exchange'];
    exchangeSpRate = data[0]['syrian_pound_exchange'];
  }

  void exchange() {
    if (trC.text != '') {
      switch (currency) {
        case 'تركي':
          num tr = num.parse(trC.text);
          num usd = tr / exchangeRate;
          widget.controller.text = usd.toStringAsFixed(2);
        case 'سوري':
          num tr = num.parse(trC.text);
          num usd = tr / exchangeSpRate;
          widget.controller.text = usd.toStringAsFixed(2);
      }
    }
  }

  @override
  void initState() {
    getRateFromDB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (currency) {
      case 'دولار':
        return Row(
          children: [
            Text(widget.label),
            Column(
              children: [],
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
                height: 30,
                width: 130,
                child: TextBox(
                  controller: widget.controller,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                )),
            SizedBox(width: 3),
            SizedBox(
                child: DropDownButton(
              title: Text(currency),
              items: [
                MenuFlyoutItem(
                    text: const Text('دولار'),
                    onPressed: () {
                      setState(() {
                        currency = 'دولار';
                      });
                    }),
                MenuFlyoutItem(
                    text: const Text('تركي'),
                    onPressed: () {
                      setState(() {
                        currency = 'تركي';
                      });
                    }),
                MenuFlyoutItem(
                    text: const Text('سوري'),
                    onPressed: () {
                      setState(() {
                        currency = 'سوري';
                      });
                    }),
              ],
            )),
          ],
        );
      case 'تركي':
        return Column(
          children: [
            Row(
              children: [
                Text(widget.label),
                Column(
                  children: [],
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                    height: 30,
                    width: 130,
                    child: TextBox(
                      controller: trC,
                      onChanged: (input) {
                        exchange();
                      },
                      textAlignVertical: TextAlignVertical.center,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    )),
                SizedBox(width: 3),
                SizedBox(
                    child: DropDownButton(
                  title: Text(currency),
                  items: [
                    MenuFlyoutItem(
                        text: const Text('دولار'),
                        onPressed: () {
                          setState(() {
                            currency = 'دولار';
                          });
                        }),
                    MenuFlyoutItem(
                        text: const Text('تركي'),
                        onPressed: () {
                          setState(() {
                            currency = 'تركي';
                          });
                        }),
                    MenuFlyoutItem(
                        text: const Text('سوري'),
                        onPressed: () {
                          setState(() {
                            currency = 'سوري';
                          });
                        }),
                  ],
                )),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('سعر الصرف'),
                SizedBox(
                  width: 3,
                ),
                Text(exchangeRate.toStringAsFixed(2)),
                SizedBox(
                  width: 4,
                ),
                SizedBox(
                  width: 5,
                ),
                IconButton(
                    icon: Icon(FluentIcons.edit),
                    onPressed: () {
                      showModifyPriceAlert(context);
                    }),
                SizedBox(
                    height: 30,
                    width: 130,
                    child: TextBox(
                      enabled: false,
                      controller: widget.controller,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    )),
                Text('دولار')
              ],
            )
          ],
        );
      case 'سوري':
        return Column(
          children: [
            Row(
              children: [
                Text(widget.label),
                Column(
                  children: [],
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                    height: 30,
                    width: 130,
                    child: TextBox(
                      controller: trC,
                      onChanged: (input) {
                        exchange();
                      },
                      textAlignVertical: TextAlignVertical.center,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    )),
                SizedBox(width: 3),
                SizedBox(
                    child: DropDownButton(
                  title: Text(currency),
                  items: [
                    MenuFlyoutItem(
                        text: const Text('دولار'),
                        onPressed: () {
                          setState(() {
                            currency = 'دولار';
                          });
                        }),
                    MenuFlyoutItem(
                        text: const Text('تركي'),
                        onPressed: () {
                          setState(() {
                            currency = 'تركي';
                          });
                        }),
                    MenuFlyoutItem(
                        text: const Text('سوري'),
                        onPressed: () {
                          setState(() {
                            currency = 'سوري';
                          });
                        }),
                  ],
                )),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('سعر الصرف'),
                SizedBox(
                  width: 3,
                ),
                Text(exchangeSpRate.toStringAsFixed(2)),
                SizedBox(
                  width: 4,
                ),
                SizedBox(
                  width: 5,
                ),
                IconButton(
                    icon: Icon(FluentIcons.edit),
                    onPressed: () {
                      showModifyPriceSpAlert(context);
                    }),
                SizedBox(
                    height: 30,
                    width: 130,
                    child: TextBox(
                      enabled: false,
                      controller: widget.controller,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    )),
                Text('دولار')
              ],
            )
          ],
        );
      default:
        return SizedBox();
    }
  }
}
