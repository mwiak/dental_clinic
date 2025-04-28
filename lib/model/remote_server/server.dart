import 'dart:convert';
import 'dart:io';
import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/model/entities/remote_user.dart';
import 'package:dental_clinic/model/remote_server/apis.dart';
import 'package:dental_clinic/shared/public_methods/datetime_methods.dart';
import 'package:dental_clinic/view_model/remote_users_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';

class ServerService {
  static final ServerService _instance = ServerService._internal();

  factory ServerService() => _instance;

  ServerService._internal();

  Function()? onClientDisconnected;
  Function()? onClientConnected;
  Function()? onClientFirstConnected;
  Function()? onServerStarted;
  Function()? onServerStopped;
  Function(Map data)? onWaitingListAdd;
  Function()? onWaitingListGet;
  Function(int)? onWaitingListRemove;

  Function()? onAuthCodeGenerated;
  Function()? onAuthCodeValidGenerated;
  Function()? onAuthCodeInvalidGenerated;
  Function()? onAuthDialogClosed;

  SqlDb dataHelper = SqlDb();
  HttpServer? server;

  List<Map<int, bool>> connectedDevices = [];

  List<RemoteUser> connections = [];

  Future<bool> checkForToken(String token, dynamic webSocket) async {
    bool matched = false;
    List data = await dataHelper.readData('''SELECT * FROM remote_user ''');
    for (Map n in data) {
      matched = n['token'] == token;
      if (matched) {
        connections.add(RemoteUser(
            id: n['id'],
            name: n['name'],
            device: n['device'],
            token: token,
            websocket: webSocket,
            isConnected: true));
        break;
      }
    }
    return matched;
  }

  void removeClient(dynamic webSocket) {
    connections.removeWhere((client) {
      return client.websocket == webSocket;
    });
  }

  Future<void> getAllSavedDevices() async {
    List data = await dataHelper.readData('''SELECT * FROM remote_user ''');

    for (Map device in data) {
      connectedDevices.add({device['id']: false});
    }
  }

  Future<String> getCenterName() async {
    List data = await dataHelper.readData('''SELECT * FROM user''');

    return data[0]['center'];
  }

  Future<int> saveNewUser(String name, String device, String token) async {
    int response = await dataHelper.insertData(
        '''INSERT INTO remote_user (name,device,token)VALUES('$name','$device','$token')''');
    return response;
  }

  String generateToken() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final Random rnd = Random.secure();

    String getRandomString() => String.fromCharCodes(Iterable.generate(
        32, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

    return getRandomString();
  }

  String ip = '127.1.2.3';

  String generateCode() {
    final rng = Random();
    return (rng.nextInt(900000) + 100000).toString(); // 6-digit code
  }

  void startServer(String localIp) async {
    final handler = webSocketHandler((webSocket) async {
      print("📡 Client connected");

      bool isAuthenticated = false;

      webSocket.stream.listen((message) async {
        print(message);
        final data = jsonDecode(message);

        if (!isAuthenticated && data['type'] == 'already') {
          isAuthenticated = await checkForToken(data['token'], webSocket);

          if (isAuthenticated) {
            webSocket.sink.add(
                jsonEncode({"type": "saved_success", "message": "welcome"}));
            onClientConnected?.call();
          } else {
            webSocket.sink
                .add(jsonEncode({"type": "forget", "message": "try again"}));
          }
          return;
        }

        if (!isAuthenticated) {
          webSocket.sink.add(jsonEncode(
              {"type": "error", "message": "You must authenticate first"}));
          return;
        }

        // After authentication, handle API
        if (data['type'] == 'ping') {
          webSocket.sink.add(jsonEncode({"type": "pong"}));
        }
        if (data['type'] == 'getAllPatients') {
          List response = await getAllPatientsAPI();
          webSocket.sink.add(jsonEncode(
              {"type": "patient_payload", "payload": response ?? 0}));
        }
        if (data['type'] == 'addToList') {
          Map patientData = data['patient_data'];
          int response = onWaitingListAdd?.call(patientData);
          webSocket.sink.add(jsonEncode(
              {"type": "waiting_list_response", "response": response}));
        }
        if (data['type'] == 'remove_from_list') {
          int id = data['id'];
          int response = onWaitingListRemove?.call(id);
          webSocket.sink.add(jsonEncode(
              {"type": "waiting_remove_response", "response": response}));
        }
        if (data['type'] == 'getWaitingList') {
          List<Map> payload = onWaitingListGet?.call();
          print(payload);
          webSocket.sink.add(jsonEncode(
              {"type": "waiting_list_get_response", "payload": payload}));
        }
        if (data['type'] == 'getSearched') {
          List patients = await getAllPatientsSearchedAPI(data['keywords']);
          webSocket.sink.add(
              jsonEncode({"type": "patient_payload", "payload": patients}));
        }
        if (data['type'] == 'add_patient') {
          String firstName = data['firstname'];
          String lastName = data['lastname'];
          String age = data['age'];
          String phone = data['phone'];
          String date = currentDateToString(DateTime.now());

          int response =
              await saveNewPatientAPI(firstName, lastName, age, phone, date);
          webSocket.sink.add(jsonEncode(
              {"type": "patient_add_response", "response": response}));
        }
      }, onDone: () {
        print("❌ Client disconnected");
        onClientConnected?.call();
        removeClient(webSocket);
        isAuthenticated = false;
      });
    });

    if (server == null) {
      server = await io.serve(handler, InternetAddress(localIp), 8080);
      print("Server started on ${server!.address.address}:${server!.port}");
    }
    onServerStarted?.call();
    print(
        "🖥️ Server running at ws://${server!.address.address}:${server!.port}");
  }

  void startNewServer(BuildContext context, String localIp) async {
    String generatedCode = generateCode();
    showAuthDialog(context, generatedCode, localIp);

    final handler = webSocketHandler((webSocket) async {
      print("📡 Client connected");

      bool isAuthenticated = false;
      String center = await getCenterName();

      webSocket.stream.listen((message) async {
        final data = jsonDecode(message);

        if (!isAuthenticated && data['type'] == 'auth') {
          String receivedCode = data['code'] ?? '';
          if (receivedCode == generatedCode) {
            // Navigator.of(context).pop();
            print("✅ Authenticated client");
            String token = generateToken();
            onAuthCodeValidGenerated?.call();
            webSocket.sink.add(jsonEncode({
              "type": "auth_success",
              "message": "Authentication successful",
              "center": center,
              "token": token
            }));
            await saveNewUser('user 1', data['device'], token);
            stopServer();
          } else {
            onAuthCodeInvalidGenerated?.call();
            webSocket.sink.add(
                jsonEncode({"type": "auth_failed", "message": "Invalid code"}));
          }
          return;
        }

        if (!isAuthenticated) {
          webSocket.sink.add(jsonEncode({
            "type": "error",
            "message": "You must authenticate first y kdeeeeesh"
          }));
          return;
        }

        // After authentication, handle API
        if (data['type'] == 'ping') {
          webSocket.sink.add(jsonEncode({"type": "pong"}));
        }
      }, onDone: () {
        print("❌ Client disconnected");
        isAuthenticated = false;
        onClientConnected?.call();
      });
    });

    if (server == null) {
      server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
      print("Server started on ${server!.address.address}:${server!.port}");
    }
    onServerStarted?.call();

    print(
        "🖥️ Server running at ws://${server!.address.address}:${server!.port}");
  }

  void stopServer() async {
    if (server != null) {
      print("Closing server...");
      await server!.close(force: true);

      server = null;
      connections = [];
      onClientConnected?.call();
      onServerStopped?.call();
      print("Server stopped");
    }
  }

  void showAuthDialog(BuildContext context, String code, String ip) async {
    await showDialog(
      context: context,
      builder: (context) => Consumer<RemoteUsersProvider>(
        builder: (context, v, child) {
          return ContentDialog(
            constraints: BoxConstraints(
                minWidth: 300, minHeight: 400, maxWidth: 300, maxHeight: 500),
            content: Column(
              children: [
                Consumer<RemoteUsersProvider>(builder: (context, value, child) {
                  if (value.loadingAuthScreenFlag == 'n') {
                    return Column(
                      children: [
                        Text('رمز التحقق'),
                        SizedBox(
                          height: 10,
                        ),
                        Text(code),
                        SizedBox(
                          height: 10,
                        ),
                        Text.rich(
                            textDirection: TextDirection.rtl,
                            TextSpan(text: 'النطاق', children: [
                              TextSpan(text: ' : '),
                              TextSpan(text: ip)
                            ]))
                      ],
                    );
                  } else if (value.loadingAuthScreenFlag == 'valid') {
                    return Column(
                      children: [
                        Lottie.asset(
                            repeat: true,
                            animate: true,
                            'assets/lottie/success_animation.json'),
                        Text(
                            'تمت إضافة الجهاز للأجهزة المحفوظة, يمكتك بدء الاتصال بتفعيل زر السماح بالاتصال'),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Lottie.asset(
                            repeat: true,
                            animate: true,
                            'assets/lottie/fail.json'),
                        Text('الكود غير صحيح, ادخل رمز التحقق بشكل صحيح'),
                        Text('رمز التحقق'),
                        SizedBox(
                          height: 10,
                        ),
                        Text(code),
                        SizedBox(
                          height: 10,
                        ),
                        Text.rich(
                            textDirection: TextDirection.rtl,
                            TextSpan(text: 'النطاق', children: [
                              TextSpan(text: ' : '),
                              TextSpan(text: ip)
                            ]))
                      ],
                    );
                  }
                }),
              ],
            ),
            actions: v.loadingAuthScreenFlag == 'valid'
                ? [
                    Button(
                        child: Text('تم'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                  ]
                : [
                    Button(
                        child: Text('إلغاء العملية'),
                        onPressed: () {
                          stopServer();
                          Navigator.of(context).pop();
                        })
                  ],
          );
        },
      ),
    );
    onAuthDialogClosed?.call();
  }
}
