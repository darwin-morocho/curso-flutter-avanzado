import 'package:adhara_socket_io/adhara_socket_io.dart';
import '../app_config.dart';

typedef void OnNewMessage(dynamic data);
typedef void OnConnected(dynamic data);
typedef void OnJoined(dynamic data);
typedef void OnDisconnected(dynamic data);

class SocketClient {
  final _manager = SocketIOManager();
  SocketIO _socket;
  OnNewMessage onNewMessage;
  OnConnected onConnected;
  OnJoined onJoined;
  OnDisconnected onDisconnected;

  connect(String token) async {
    final options = SocketOptions(AppConfig.socketHost,
        query: {"token": token}, enableLogging: false);

    _socket = await _manager.createInstance(options);

    _socket.on('connected', (data) {
      if(onConnected!=null){
        onConnected(data);
      }
    });

    _socket.on('joined', (data) {
      if(onJoined!=null){
        onJoined(data);
      }
    });

    _socket.on('disconnected', (data) {
      print("disconnected: ${data.toString()}");
      if(onDisconnected!=null){
        onDisconnected(data);
      }
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
