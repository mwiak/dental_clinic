import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dental_clinic/database/sqflite.dart';
import 'package:dental_clinic/model/entities/remote_user.dart';
import 'package:dental_clinic/model/entities/waiting_list_patient.dart';
import 'package:dental_clinic/model/remote_server/server.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:test/expect.dart';
import 'package:udp/udp.dart';

class RemoteUsersProvider extends ChangeNotifier {
  RemoteUsersProvider() {
    getAllSavedUsers();

    serverService.onClientDisconnected = () {
      refreshConnection();
    };
    serverService.onClientConnected = () {
      refreshConnection();
    };

    serverService.onClientFirstConnected = () {
      refreshConnection();
      stopServer();
    };
    serverService.onWaitingListAdd = (data) {
      int response = addPatientToWaitingList(data);
      return response;
    };
    serverService.onWaitingListGet = () {
      List data = getWaitingListPatientsInMaps();
      return data;
    };
    serverService.onWaitingListRemove = (int id) {
      int response = removePatientFromWaitingList(id);
      return response;
    };

    serverService.onAuthCodeValidGenerated = () {
      loadingAuthScreenFlag = 'valid';
      notifyListeners();
    };

    serverService.onAuthCodeInvalidGenerated = () {
      loadingAuthScreenFlag = 'invalid';
      notifyListeners();
    };

    serverService.onAuthDialogClosed = () {
      loadingAuthScreenFlag = 'n';
    };
  }
  SqlDb dataHelper = SqlDb();

  ServerService serverService = ServerService();

  List<RemoteUser> connectionStatus = [];

  List<Map> devices = [];

  List<WaitingListPatient> waitingList = [];

  bool _isServing = false;
  bool get isServing => _isServing;
  bool isBroadcasting = false;

  UDP? sender;

  String loadingAuthScreenFlag = 'n';

  Future<String?> getLocalIp() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );

    for (var interface in interfaces) {
      // You can optionally filter by interface.name if needed
      for (var addr in interface.addresses) {
        print("Interface ${interface.name}: ${addr.address}");

        // Common private IP ranges
        if (!addr.isLoopback &&
            (addr.address.startsWith('192.168.0.') ||
                addr.address.startsWith('10.'))) {
          print(addr.address);
          return addr.address;
        }
      }
    }

    return null;
  }

  void startBroadcast(String ip, int port) async {
    isBroadcasting = true;
    sender = await UDP.bind(Endpoint.any());
    print('binding udp');

    final message = 'my_server_ip=$ip;port=$port';

    while (isBroadcasting) {
      await sender!.send(
        utf8.encode(message),
        Endpoint.broadcast(port: Port(45678)),
      );
      await Future.delayed(Duration(seconds: 2)); // adjust interval
    }
  }

  void stopBroadcast() async {
    if (sender != null) {
      sender!.close();
      isBroadcasting = false;
      sender = null;
    } else {}
  }

  void startServerLogic() async {
    String? ip = await getLocalIp();
    if (ip != null) {
      startBroadcast(ip, 8080);
      startServer(ip);
    }
  }

  void startNewServerLogic(BuildContext context) async {
    String? ip = await getLocalIp();
    if (ip != null) {
      startBroadcast(ip, 8080);
      startNewServer(context, ip);
    }
  }

  void toggleServing(bool val) {
    _isServing = val;
    notifyListeners();
  }

  void startNewServer(BuildContext context, String ip) {
    serverService.startNewServer(context, ip);
  }

  void startServer(String ip) async {
    serverService.startServer(ip);
  }

  void refreshConnection() async {
    connectionStatus = serverService.connections;
    await getAllSavedUsers();
    notifyListeners();
  }

  void stopServer() async {
    stopBroadcast();
    serverService.stopServer();
    await Future.delayed(Duration(seconds: 2));
    connectionStatus = [];
    await getAllSavedUsers();
    toggleServing(false);
    notifyListeners();
  }

  Future<void> getAllSavedUsers() async {
    List<Map<String, dynamic>> data =
        await dataHelper.readData('SELECT * FROM remote_user');

    List<Map<String, dynamic>> dataWithBools = data.map((device) {
      bool isConnected = false;

      RemoteUser? client = connectionStatus.cast<RemoteUser?>().firstWhere(
            (client) => client?.id == device['id'],
            orElse: () => null,
          );

      if (client != null) {
        isConnected = true;
      }

      return {
        ...device,
        'flag': isConnected,
      };
    }).toList();

    devices = dataWithBools;
    notifyListeners();
  }

  Future<void> deleteUser(int id) async {
    int response = await dataHelper
        .deleteData('''DELETE FROM remote_user WHERE id = $id ''');
    await getAllSavedUsers();
    serverService.stopServer();
    notifyListeners();
  }

  int addPatientToWaitingList(Map patientData) {
    WaitingListPatient patient = WaitingListPatient(data: patientData);
    if (waitingList.any((p) => p.id == patient.id)) {
      return 0;
    } else {
      waitingList.add(patient);
      notifyListeners();
      return 1;
    }
  }

  int removePatientFromWaitingList(int id) {
    waitingList.removeWhere((p) => p.id == id);
    bool exists = waitingList.any((p) => p.id == id);
    notifyListeners();
    if (exists) {
      return 0;
    } else {
      return 1;
    }
  }

  List<Map> getWaitingListPatientsInMaps() {
    List<Map> data = [];

    data = waitingList.map((item) {
      return {
        'id': item.id,
        'firstname': item.firstname,
        'lastname': item.lastname,
        'age': item.age,
      };
    }).toList();

    return data;
  }

  Future<void> modifyRemoteUserName(String name, int id) async {
    int response = await dataHelper.updateData(
        '''UPDATE  remote_user SET name = '$name' WHERE id = $id  ''');
    await getAllSavedUsers();
    notifyListeners();
  }

  void showAuthDialog(BuildContext context, String code) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text('j'),
        content: Column(
          children: [
            Text('auth code:'),
            SizedBox(
              height: 10,
            ),
            Text(code),
          ],
        ),
        actions: [
          Button(
              child: Text('stop'),
              onPressed: () {
                // stopServer();
                Navigator.of(context).pop();
              })
        ],
      ),
    );
  }
}
