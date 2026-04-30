import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../models/usuario_model.dart';
import '../services/socket_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  final SocketService _socketService;

  UsuarioModel? _usuario;
  bool _isLoading = false;
  String? _token;

  AuthProvider(this._repository, this._socketService);

  UsuarioModel? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get token => _token;

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _usuario = await _repository.register(username, email, password);
      _token = _usuario?.token;

      if (_token != null) {
        _socketService.connect(_token!);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _usuario = await _repository.login(email, password);
      _token = _usuario?.token;

      if (_usuario != null) {
        await cargarInventarioCompleto();

        if (_token != null) {
          _socketService.connect(_token!); //Conexion global por socket
        }
      }
    } catch (e) {
      _usuario = null;
      _token = null;
      _socketService.disconnect();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 6. MÉTODO DE LOGOUT (Muy importante para la arquitectura global)
  void logout() {
    _usuario = null;
    _token = null;
    _socketService.disconnect(); // Apagamos el túnel al salir
    notifyListeners();
  }

  Future<void> cargarInventarioCompleto() async {
    if (_usuario == null) return;
    try {
      final resultados = await Future.wait([
        _repository.obtenerAvataresComprados(),
        _repository.obtenerEstilosComprados(),
      ]);
      _usuario = _usuario!.copyWith(
        avataresComprados: resultados[0],
        estilosComprados: resultados[1],
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Error al cargar inventario: $e");
    }
  }

  void actualizarMonedas(int nuevaCantidad) {
    if (_usuario != null) {
      _usuario = _usuario!.copyWith(monedas: nuevaCantidad);
      notifyListeners();
    }
  }

  void registrarCompraExitosa(int idComprado, int nuevoSaldo, {required bool esAvatar}) {
    if (_usuario == null) return;
    final listaActual = esAvatar ? _usuario!.avataresComprados : _usuario!.estilosComprados;
    final nuevaLista = {...listaActual, idComprado}.toList();
    _usuario = esAvatar
        ? _usuario!.copyWith(avataresComprados: nuevaLista)
        : _usuario!.copyWith(estilosComprados: nuevaLista);
    actualizarMonedas(nuevoSaldo);
  }

  void actualizarAvatarSeleccionado(int avatarId, {String? image}) {
    if (_usuario == null) return;
    _usuario = _usuario!.copyWith(
      idAvatarSeleccionado: avatarId,
      avatarImage: image,
    );
    notifyListeners();
  }

  void actualizarEstiloSeleccionado(int estiloId, {String? image}) {
    if (_usuario == null) return;
    _usuario = _usuario!.copyWith(
      idEstiloSeleccionado: estiloId,
      estiloImage: image,
    );
    notifyListeners();
  }
}
