import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/model/entities/cost_entity.dart';
import 'package:dental_clinic/shared/custom_widgets/barboxes.dart';
import 'package:dental_clinic/shared/custom_widgets/cost_box.dart';
import 'package:dental_clinic/shared/custom_widgets/date_pickers.dart';
import 'package:dental_clinic/shared/custom_widgets/headers.dart';
import 'package:dental_clinic/shared/custom_widgets/payment_entry.dart';
import 'package:dental_clinic/shared/custom_widgets/text_boxes.dart';
import 'package:dental_clinic/shared/custom_widgets/total_card.dart';
import 'package:dental_clinic/shared/public_methods/datetime_methods.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/custom_widgets/flyout.dart';

class PatientPayments extends StatefulWidget {
  final int patientId;
  const PatientPayments({super.key, required this.patientId});

  @override
  State<PatientPayments> createState() => _PatientPaymentsState();
}

class _PatientPaymentsState extends State<PatientPayments> {
  int index = 0;
  SqlDb dataHelper = SqlDb();
  TextEditingController causeC = TextEditingController();
  TextEditingController paymentC = TextEditingController();
  TextEditingController dateC = TextEditingController();
  TextEditingController notesC = TextEditingController();

  Future<List> getAllPayments() async {
    List data = await dataHelper.readData(
        ''' SELECT * FROM payments WHERE patient_id = ${widget.patientId}''');
    return data;
  }

  Future<List> getAllCosts() async {
    List dataTreatments = await dataHelper.readData(
        ''' SELECT * FROM treatments WHERE patient_id = ${widget.patientId}''');
    List dataGeneralTreatments = await dataHelper.readData(
        ''' SELECT * FROM general_treatments WHERE patient_id = ${widget.patientId}''');

    List dataImplants = await dataHelper.readData(
        ''' SELECT * FROM implants WHERE patient_id = ${widget.patientId}''');

    List<CostEntity> treatments = dataTreatments.map((treatment) {
      return CostEntity.fromTreatmentMap(treatment);
    }).toList();
    List<CostEntity> generalTreatments = dataGeneralTreatments.map((treatment) {
      return CostEntity.fromGeneralTreatmentMap(treatment);
    }).toList();
    List<CostEntity> implants = dataImplants.map((treatment) {
      return CostEntity.fromImplantMap(treatment);
    }).toList();

    List data = treatments + generalTreatments + implants;
    data.sort((a, b) => a.date.compareTo(b.date));

    return data;
  }

  Future<List> getTotalSummary() async {
    List dataPayments = await dataHelper.readData(
        ''' SELECT SUM(amount) as total FROM payments WHERE patient_id = ${widget.patientId}''');
    List dataTreatments = await dataHelper.readData(
        ''' SELECT SUM(cost) as total FROM treatments WHERE patient_id = ${widget.patientId}''');
    List dataGeneralTreatments = await dataHelper.readData(
        ''' SELECT SUM(cost) as total FROM general_treatments WHERE patient_id = ${widget.patientId}''');

    List dataImplants = await dataHelper.readData(
        ''' SELECT SUM(cost) as total FROM implants WHERE patient_id = ${widget.patientId}''');

    num totalPayments = dataPayments[0]['total'] ?? 0;
    num totalTreatments = dataTreatments[0]['total'] ?? 0;
    num totalGeneralTreatments = dataGeneralTreatments[0]['total'] ?? 0;
    num totalImplants = dataImplants[0]['total'] ?? 0;
    num totalCost = totalTreatments + totalGeneralTreatments + totalImplants;
    List data = [totalCost, totalPayments];

    return data;
  }

  Future<void> saveNewPayment(
      String cause, num amount, String date, String notes) async {
    int response = await dataHelper.insertData(
        ''' INSERT INTO payments (patient_id,title,amount,date,notes) VALUES (${widget.patientId}, '$cause',$amount, '$date' , '$notes') ''');
    if (response > 0) {
      Navigator.of(context).pop();
      setState(() {});
    } else {}
  }

  Future<void> modifyPayment(
      int id, String cause, num amount, String date, String notes) async {
    int response = await dataHelper.updateData(
        ''' UPDATE payments SET title = '$cause', amount = $amount ,date = '$date',notes = '$notes' WHERE id = $id ''');
    if (response > 0) {
      Navigator.of(context).pop();
      setState(() {});
    } else {
      showBar(
          context, AppLocalizations.of(context)!.failed, InfoBarSeverity.error);
    }
  }

  Future<void> deletePayment(int id) async {
    int response =
        await dataHelper.deleteData(''' DELETE FROM payments WHERE id = $id''');
    if (response > 0) {
      Navigator.of(context).pop();
      setState(() {});
    } else {
      showBar(context, AppLocalizations.of(context)!.message_generic_success,
          InfoBarSeverity.error);
    }
  }

  void validateAddPayment() {
    if (paymentC.text.isNotEmpty && dateC.text.isNotEmpty) {
      String cause = causeC.text.trim();
      num amount = num.parse(paymentC.text);
      String date = dateC.text;
      String notes = notesC.text.trim();
      saveNewPayment(cause, amount, date, notes);
    } else {
      showBar(context, AppLocalizations.of(context)!.title_required,
          InfoBarSeverity.warning);
    }
  }

  void validateModifyPayment(int id) {
    if (paymentC.text.isNotEmpty && dateC.text.isNotEmpty) {
      String cause = causeC.text.trim();
      num amount = num.parse(paymentC.text);
      String date = dateC.text;
      String notes = notesC.text.trim();
      modifyPayment(id, cause, amount, date, notes);
    } else {
      showBar(context, AppLocalizations.of(context)!.title_required,
          InfoBarSeverity.warning);
    }
  }

  void showAddPaymentDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: BoxConstraints(maxHeight: 500, maxWidth: 550),
          title: Text(AppLocalizations.of(context)!.add_payment),
          content: Column(
            children: [
              MouseRegion(
                onHover: null,
                child: InfoEntrySmall(
                  controller: causeC,
                  label: AppLocalizations.of(context)!.payment_cause,
                  readOnly: true,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              PriceFieldE(
                  label: AppLocalizations.of(context)!.amount,
                  controller: paymentC),
              SizedBox(
                height: 5,
              ),
              DatePickerBasic(
                label: AppLocalizations.of(context)!.payment_date,
                value: dateC,
                requiredSymbol: '*',
              ),
              SizedBox(
                height: 5,
              ),
              InputText(
                  controller: notesC,
                  label: AppLocalizations.of(context)!.notes),
              SizedBox(
                height: 10,
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
              onPressed: () {
                validateAddPayment();
              },
            ),
          ],
        );
      }),
    );
    causeC.clear();
    paymentC.clear();
    dateC.clear();
    notesC.clear();
  }

  void showAddFillingPaymentDialog(
      BuildContext context, num amount, String cause) async {
    causeC.text = cause;
    paymentC.text = amount.toStringAsFixed(2);
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: BoxConstraints(maxHeight: 500, maxWidth: 550),
          title: Text(AppLocalizations.of(context)!.add_payment),
          content: Column(
            children: [
              MouseRegion(
                onHover: null,
                child: InfoEntrySmall(
                  controller: causeC,
                  label: AppLocalizations.of(context)!.payment_cause,
                  readOnly: true,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              PriceFieldE(
                  label: AppLocalizations.of(context)!.amount,
                  controller: paymentC),
              SizedBox(
                height: 5,
              ),
              DatePickerBasic(
                label: AppLocalizations.of(context)!.payment_date,
                value: dateC,
                requiredSymbol: '*',
              ),
              SizedBox(
                height: 5,
              ),
              InputText(
                  controller: notesC,
                  label: AppLocalizations.of(context)!.notes),
              SizedBox(
                height: 10,
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
              onPressed: () {
                validateAddPayment();
              },
            ),
          ],
        );
      }),
    );
    causeC.clear();
    paymentC.clear();
    dateC.clear();
    notesC.clear();
  }

  void showModifyPaymentDialog(BuildContext context, Map paymentData) async {
    int paymentId = paymentData['id'];
    causeC.text = paymentData['title'];
    paymentC.text = paymentData['amount'].toStringAsFixed(2);
    dateC.text = paymentData['date'];
    notesC.text = paymentData['notes'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, s) {
        return ContentDialog(
          constraints: BoxConstraints(maxHeight: 500, maxWidth: 550),
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.generic_modify),
              Spacer(),
              BasicFlyout(
                  warning: AppLocalizations.of(context)!.generic_warning,
                  onProceed: () {
                    deletePayment(paymentId);
                  },
                  action:
                      AppLocalizations.of(context)!.generic_delete_confirmation,
                  buttonText: AppLocalizations.of(context)!.generic_delete)
            ],
          ),
          content: Column(
            children: [
              MouseRegion(
                onHover: null,
                child: InfoEntrySmall(
                  controller: causeC,
                  label: AppLocalizations.of(context)!.payment_cause,
                  readOnly: true,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              PriceFieldE(
                  label: AppLocalizations.of(context)!.amount,
                  controller: paymentC),
              SizedBox(
                height: 5,
              ),
              DatePickerBasic(
                label: AppLocalizations.of(context)!.payment_date,
                value: dateC,
                requiredSymbol: '*',
              ),
              SizedBox(
                height: 5,
              ),
              InputText(
                  controller: notesC,
                  label: AppLocalizations.of(context)!.notes),
              SizedBox(
                height: 10,
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
              child: Text(AppLocalizations.of(context)!.generic_modify),
              onPressed: () {
                validateModifyPayment(paymentId);
              },
            ),
          ],
        );
      }),
    );
    causeC.clear();
    paymentC.clear();
    dateC.clear();
    notesC.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder(
                    future: getTotalSummary(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox.shrink();
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else if (snapshot.data!.isEmpty) {
                        return SizedBox.shrink();
                      } else {
                        num totalCost = snapshot.data![0];
                        num totalPaid = snapshot.data![1];
                        return SummaryCard(
                            totalCost: totalCost, totalPaid: totalPaid);
                      }
                    })
              ],
            ),
          ),
          Expanded(
            flex: 8,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                    child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.payments),
                          SizedBox(
                            width: 5,
                            height: 30,
                          ),
                          IconButton(
                              icon: Icon(FluentIcons.add),
                              onPressed: () {
                                showAddPaymentDialog(context);
                              })
                        ],
                      )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    BasicHeader(
                        title1: AppLocalizations.of(context)!.payment_cause,
                        title2: AppLocalizations.of(context)!.amount,
                        title3: AppLocalizations.of(context)!.payment_date),
                    Divider(),
                    Flexible(
                      child: FutureBuilder(
                          future: getAllPayments(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox.shrink();
                            } else if (snapshot.hasError) {
                              return SizedBox.shrink();
                            } else if (snapshot.data == 0) {
                              return Text(
                                  AppLocalizations.of(context)!.no_data);
                            } else {
                              return SizedBox(
                                child: ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, i) {
                                      int id = snapshot.data![i]['id'];
                                      String title = snapshot.data![i]['title'];
                                      num amount = snapshot.data![i]['amount'];
                                      String date = snapshot.data![i]['date'];
                                      String notes = snapshot.data![i]['notes'];
                                      return PaymentSEntry(
                                        id: id,
                                        title: title,
                                        amount: amount,
                                        date: date,
                                        notes: notes,
                                        onTap: () {
                                          showModifyPaymentDialog(
                                              context, snapshot.data![i]);
                                        },
                                      );
                                    }),
                              );
                            }
                          }),
                    )
                  ],
                )),
                Divider(
                  direction: Axis.vertical,
                ),
                Expanded(
                    child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.invoices),
                          SizedBox(
                            height: 30,
                          )
                        ],
                      )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    BasicHeader(
                        title1: AppLocalizations.of(context)!.invoice_cause,
                        title2: AppLocalizations.of(context)!.amount,
                        title3: AppLocalizations.of(context)!.invoice_date),
                    Divider(),
                    Flexible(
                      child: FutureBuilder(
                          future: getAllCosts(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox.shrink();
                            } else if (snapshot.hasError) {
                              return SizedBox.shrink();
                            } else if (snapshot.data?.length == 0) {
                              return Text(
                                  AppLocalizations.of(context)!.no_data);
                            } else {
                              return SizedBox(
                                child: ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, i) {
                                      String title = snapshot.data![i].type;
                                      num amount = snapshot.data![i].amount;
                                      String date = currentDateToString(
                                          snapshot.data![i].date);

                                      return PaymentEntry(
                                        title: title,
                                        amount: amount,
                                        date: date,
                                        notes: '',
                                        onPay: () {
                                          showAddFillingPaymentDialog(
                                              context, amount, title);
                                        },
                                      );
                                    }),
                              );
                            }
                          }),
                    )
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
