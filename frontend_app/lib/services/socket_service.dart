import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import '../app/api_config.dart';

class SocketService with ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  /// True si hay un socket creado (aunque no esté actualmente conectado).
  /// Los wrappers `on`/`off`/`emitir` necesitan al menos un socket para
  /// poder registrar handlers o encolar emisiones.
  bool get hasSocket => _socket != null;

  /// Registra un handler para `event`. Hace nada si no hay socket.
  /// Wrapper sobre `socket.on` para poder testear sin instanciar IO.Socket.
  void on(String event, dynamic Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  /// Elimina TODOS los handlers de `event` (mismo comportamiento que
  /// `socket.off(event)` sin pasar callback). Hace nada si no hay socket.
  void off(String event) {
    _socket?.off(event);
  }

  void connect(String token) {
    debugPrint("🔌 [SOCKET SERVICE] Intentando conectar...");
    debugPrint("🔌 [SOCKET SERVICE] URL: ${ApiConfig.socketUrl}");

    // Idempotente: si ya existe un socket (conectado, conectándose o
    // reconectándose), NO creamos otro. Reasignar destruye listeners que
    // ya tenía registrado el resto de la app (p. ej. el VM de partida).
    // Para forzar un reseteo completo, llama antes a `disconnect()`.
    if (_socket != null) {
      debugPrint(
        "🔌 [SOCKET SERVICE] Ya hay socket existente (connected=${_socket!.connected}). No creamos otro.",
      );
      // Si está desconectado, le pedimos que se reconecte (preserva listeners).
      if (!_socket!.connected) {
        _socket!.connect();
      }
      return;
    }

    _socket = IO.io(
      ApiConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
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

    _socket!.onConnectError(
          (data) => debugPrint('Error en la conexión Socket: $data'),
    );

    _socket!.onAny((event, data) {
      debugPrint("📡 [SOCKET EVENT] $event → $data");
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    notifyListeners();
  }

  // Método genérico para emitir eventos
  void emitir(String evento, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket?.emit(evento, data);
    } else {
      debugPrint('Aviso: Intento de emitir "$evento" pero el socket no está conectado.');
    }
  }
}