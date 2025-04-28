class RemoteUser {
  late int id;
  late String name;
  late String device;
  late String token;
  late dynamic websocket;
  bool isConnected = false;

  RemoteUser(
      {required this.id,
      required this.name,
      required this.device,
      required this.token,
      required this.websocket,
      required this.isConnected});
}
