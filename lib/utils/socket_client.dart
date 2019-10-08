import 'package:adhara_socket_io/adhara_socket_io.dart';
import '../app_config.dart';

typedef void OnNewMessage(dynamic data);

class SocketClient {
  final _manager = SocketIOManager();
  SocketIO _socket;
  OnNewMessage onNewMessage;

  connect(String token) async {
    final options = SocketOptions(AppConfig.socketHost,
        query: {"token": token}, enableLogging: false);

    _socket = await _manager.createInstance(options);

    _socket.on('connected', (data) {
      print("connected: ${data.toString()}");
    });

    _socket.on('joined', (data) {
      print("joined: ${data.toString()}");
    });

    _socket.on('new-message', (data) {
      if (onNewMessage != null) {
        onNewMessage(data);
      }
    });

    _socket.onError((error) {
      print("on Error: ${error.toString()}");
    });

    _socket.connect();
  }


  emit(String eventName,dynamic data){
    _socket.emit(eventName, [data]);
  }

  disconnect() async {
    await _manager.clearInstance(_socket);
  }
}
