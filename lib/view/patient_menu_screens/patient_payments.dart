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

  void validateAddPayment() {
    if (paymentC.text.isNotEmpty && dateC.text.isNotEmpty) {
      String cause = causeC.text.trim();
      num amount = num.parse(paymentC.text);
      String date = dateC.text;
      String notes = notesC.text.trim();
      saveNewPayment(cause, amount, date, notes);
    } else {
      showBar(context, '* required', InfoBarSeverity.warning);
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
              CostBox(
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
                              return Text('no data');
                            } else {
                              return SizedBox(
                                width: 500,
                                child: ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, i) {
                                      String title = snapshot.data![i]['title'];
                                      num amount = snapshot.data![i]['amount'];
                                      String date = snapshot.data![i]['date'];
                                      String notes = snapshot.data![i]['notes'];
                                      return PaymentEntry(
                                          title: title,
                                          amount: amount,
                                          date: date,
                                          notes: notes);
                                    }),
                              );
                            }
                          }),
                    )
                  ],
                )),
                Expanded(
                    child: Column(
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
                            } else if (snapshot.data == 0) {
                              return Text(
                                  AppLocalizations.of(context)!.no_data);
                            } else {
                              return SizedBox(
                                width: 500,
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
                                          notes: '');
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
