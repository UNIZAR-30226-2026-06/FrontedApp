import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class SocketService with ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  void connect(String token) {
    _socket = IO.io('http://10.0.2.2:3000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .build()
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('Socket conectado: ${_socket!.id}');
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('Socket desconectado');
      notifyListeners();
    });

    _socket!.onConnectError((data) => debugPrint('Error en la conexión: $data'));
  }

  void disconnect() {
    _socket?.disconnect();
  }

  // Método genérico para emitir eventos
  void emitir(String evento, dynamic data) {
    _socket?.emit(evento, data);
  }
}